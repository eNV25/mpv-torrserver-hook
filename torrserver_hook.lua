-- torrserver_hook.lua

local mp = require("mp")
local msg = require("mp.msg")
local options = require("mp.options")
local utils = require("mp.utils")

local opts = {
	server = "http://localhost:8090",
}

options.read_options(opts)

local base_url = utils.join_path(opts.server, "stream?m3u&link=")

local function encodeURIComponent(str)
	-- copied from https://github.com/daurnimator/lua-http/blob/master/http/util.lua
	-- MIT License, Copyright (c) 2015-2021 Daurnimator
	return str:gsub("[^%w%-_%.%!%~%*%'%(%)]", function(c)
		return string.format("%%%02X", c:byte(1, 1))
	end)
end

mp.add_hook("on_load", 50, function()
	local url = mp.get_property("stream-open-filename")
	--if url:match("^magnet:.*[?&]xt=urn:bt[im]h:(%w*)&?") then
	if url:match("^magnet:.*[?&]xt=urn:btih:(%w*)&?") then
		msg.debug("using " .. url)
		mp.set_property("stream-open-filename", base_url .. encodeURIComponent(url))
	elseif url:match("%.torrent$") then
		local res, err = utils.file_info(url)
		if err then -- if is not local file then
			msg.debug("using " .. url)
			mp.set_property("stream-open-filename", base_url .. encodeURIComponent(url))
		else -- if is local file
			msg.debug("uploading " .. url)
			res, err = mp.command_native({
				name = "subprocess",
				capture_stdout = true,
				playback_only = false,
				args = {
					"curl",
					"--no-progress-meter",
					"--variable",
					"url=" .. url,
					"--expand-form",
					"file=@{{url}}",
					"--header",
					"accept: application/json",
					utils.join_path(opts.server, "torrent/upload"),
				},
			})
			if err then
				msg.error(err)
				return
			end
			local hash = utils.parse_json(res.stdout).hash
			msg.debug("using " .. hash)
			mp.set_property("stream-open-filename", base_url .. hash)
		end
	end
end)

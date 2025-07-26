-- torrserver_hook.lua

local mp = require("mp")
local msg = require("mp.msg")
local options = require("mp.options")
local utils = require("mp.utils")

local opts = {
	server = "http://localhost:8090",
	rewrite = false,
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

local function upload_torrent_file(url)
	msg.debug("uploading " .. url)
	local res, err = mp.command_native({
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
	return utils.parse_json(res.stdout).hash
end

local function set_stream_open_filename(url)
	if opts.rewrite then
		msg.debug("rewriting " .. url)
		local res, err = mp.command_native({
			name = "subprocess",
			capture_stdout = true,
			playback_only = false,
			args = {
				"curl",
				"--no-progress-meter",
				url,
			},
		})
		if err then
			msg.error(err)
			return
		end
		url = res.stdout:gsub("http://.-/stream/", utils.join_path(opts.server, "stream/"))
		mp.set_property("stream-open-filename", "memory://" .. url)
	else
		msg.debug("using " .. url)
		mp.set_property("stream-open-filename", url)
	end
end

mp.add_hook("on_load", 50, function()
	msg.debug("torrserver hook")
	local url = mp.get_property("stream-open-filename")
	if url:match("^magnet:.*[?&]xt=urn:bt[im]h:(%w*)&?") then
		set_stream_open_filename(base_url .. encodeURIComponent(url))
	elseif url:match("%.torrent$") or url:match("%.torrent[?#].-$") then
		local _, err = utils.file_info(url)
		if err then -- if is not local file then
			set_stream_open_filename(base_url .. encodeURIComponent(url))
		else -- if is local file
			local hash = upload_torrent_file(url)
			set_stream_open_filename(base_url .. hash)
		end
	end
end)

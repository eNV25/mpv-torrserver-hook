-- This script hooks into mpv's load process to redirect magnet links
-- to a Torrserver instance.
--
-- It supports two formats:
-- 1. Standard magnet links -> [server]/stream?m3u&link=[magnet]
-- 2. Magnet links with an index -> [server]/stream?play&index=[N]&link=[magnet]
--
-- This version is modified for Android use, removing curl and file support.

local mp = require("mp")
local msg = require("mp.msg")
local options = require("mp.options")
local utils = require("mp.utils")

local opts = {
	-- Set your Torrserver address here
	server = "http://localhost:8090",
}

-- Base URL for standard magnet links (streams playlist)
local m3u_base_url = utils.join_path(opts.server, "stream?m3u&link=")
-- Base URL for magnet links with a file index (direct play)
local play_base_url = utils.join_path(opts.server, "stream?play")

---
-- Encodes a string for use in a URL component.
-- @param str The string to encode.
-- @return The URL-encoded string.
--
local function encodeURIComponent(str)
	-- copied from https://github.com/daurnimator/lua-http/blob/master/http/util.lua
	-- MIT License, Copyright (c) 2015-2021 Daurnimator
	return str:gsub("[^%w%-_%.%!%~%*%'%(%)]", function(c)
		return string.format("%%%02X", c:byte(1, 1))
	end)
end

---
-- Sets the 'stream-open-filename' property to the new URL.
-- This tells mpv to open the Torrserver stream instead of the
-- original magnet link.
-- @param url The new URL to open.
--
local function set_stream_url(url)
	msg.debug("Redirecting to " .. url)
	mp.set_property("stream-open-filename", url)
end

-- Hook into the 'on_load' event, running with high priority (50)
-- to catch the URL before other scripts.
mp.add_hook("on_load", 50, function()
	msg.debug("Torrserver hook running...")
	local url = mp.get_property("stream-open-filename")

	if url:match("^magnet:.*[?&]xt=urn:bt[im]h:(%w*)&?") then
		-- Check for the new format: magnet:...&index=N
		-- We specifically look for '&index=' or '?index='
		local index = url:match("[?&]index=(%d+)")

		if index then
			-- New format found: magnet link with a file index
			msg.debug("Found magnet with index: " .. index)
			local encoded_magnet = encodeURIComponent(url)
			-- Construct the direct play URL: /stream?play&index=N&link=MAGNET
			local stream_url = string.format("%s&index=%s&link=%s", play_base_url, index, encoded_magnet)
			set_stream_url(stream_url)
		else
			-- Standard magnet link (without an index)
			msg.debug("Found standard magnet link")
			local encoded_magnet = encodeURIComponent(url)
			-- Construct the playlist URL: /stream?m3u&link=MAGNET
			local stream_url = m3u_base_url .. encoded_magnet
			set_stream_url(stream_url)
		end
	end
end)

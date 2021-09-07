local wibox = require('wibox')
local spawn = require('awful.spawn')
local gtimer = require('gears.timer')
local gsurface = require('gears.surface')
local shape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local album_cover = require 'widget.music-player.album-cover'
local song_dates = require 'widget.music-player.song-dates'
local media_buttons = require 'widget.music-player.media-buttons'

local get_artist = [[dbus-send --print-reply --type=method_call --dest='org.gnome.Lollypop' /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 2 "artist" | egrep -v "artist" | egrep -v "array" | awk -F '"' '{print $2}' ]]

local get_title = [[dbus-send --print-reply --type=method_call --dest='org.gnome.Lollypop' /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 1 "title" | egrep -v "title" | awk -F '"' '{print $2}' ]]

local get_cover = [[dbus-send --print-reply --type=method_call --dest='org.gnome.Lollypop' /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 1 "artUrl" | egrep -v "artUrl" | awk -F '"' '{print $2}' ]]

local get_status = [[dbus-send --print-reply --type=method_call --dest='org.gnome.Lollypop' /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus' | grep -A 1 "string" | awk -F '"' '{print $2}']]


local function update_artist()
	spawn.easy_async({ 'bash', '-c', get_artist }, function(stdout)
		song_dates.artist:set_text(stdout:gsub('%\n', ''))
	end)
end

local function update_title()
	spawn.easy_async({ 'bash', '-c', get_title }, function(stdout)
		song_dates.title:set_text(stdout:gsub('%\n', ''))
	end)
end

local function update_cover()
	spawn.easy_async({ 'bash', '-c', get_cover }, function(stdout)
		local cover_img = stdout:gsub('%\n', ''):sub(8, -1)

		if not cover_img then
			album_cover.cover:set_image(gsurface.load_uncached(beautiful.icon_player_music))
		else
			album_cover.cover:set_image(gsurface.load_uncached(cover_img))
		end

		collectgarbage('collect')
	end)
end

local function check_if_playing()
	spawn.easy_async({ 'bash', '-c', get_status }, function(stdout)
		if stdout:match('Playing') then
			awesome.emit_signal('player::status', true)
		else
			awesome.emit_signal('player::status', false)
		end
	end)
end

local timer = gtimer {
	timeout = 3,
	autostart = false,
	call_now = true,
	callback = function()
		update_artist()
		update_title()
		update_cover()
		check_if_playing()
	end
}

awesome.connect_signal('popup::visible', function( visible )
	if visible then
		timer:start()
		timer:emit_signal('timeout')
	else
		timer:stop()
	end
end)

local wibox     = require('wibox')
local button    = require('awful.button')
local shape     = require('gears.shape')
local timer     = require('gears.timer')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

require 'widget.music-player.updater'
local media_buttons = require 'widget.music-player.media-buttons'
local album_cover   = require 'widget.music-player.album-cover'
local song_dates    = require 'widget.music-player.song-dates'
local music_player_large = require 'widget.music-player.large'

local time_to_expand = timer {
	timeout = 0.5,
	autostart = false,
	callback = function(self)
		awesome.emit_signal('popup::change_widget', music_player_large)
		self:stop()
	end
}

local music_player = wibox.widget
{
	layout = wibox.container.background,
	bg = beautiful.bg_card,
	shape = shape.rounded_rect,
	forced_height = dpi(60),
	buttons = {
		button({}, 1, function() time_to_expand:start() end, function() time_to_expand:stop() end)
	},
	{
		layout = wibox.container.margin,
		margins = dpi(10),
		{
			layout = wibox.layout.align.horizontal,
			{
				layout = wibox.container.margin,
				right = dpi(10),
				album_cover
			},
			song_dates.dates,
			{
				layout = wibox.container.margin,
				left = dpi(10),
				top = dpi(10),
				bottom = dpi(10),
				media_buttons
			}
		}
	}
}

return music_player

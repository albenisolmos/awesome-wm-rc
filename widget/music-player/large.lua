local wibox     = require('wibox')
local button    = require('awful.button')
local timer     = require('gears.timer')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local media_buttons = require 'widget.music-player.media-buttons'
local album_cover   = require 'widget.music-player.album-cover'
local dates         = require 'widget.music-player.song-dates'

--dates.artist.align = 'center'
--dates.title.align = 'center'

local large = wibox.widget
{
	layout = wibox.container.background,
	bg = beautiful.transparent,
	shape = shape.rounded_rect,
	forced_height = dpi(350),
	{
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(10),
		album_cover,
		dates.dates,
		media_buttons,
	}
}

return large

local shape     = require('gears.shape')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local song_date = {}

local title = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.font_bold,
	align = 'left',
}

local artist = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.font,
	align = 'left',
}

local dates = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	expand = 'none',
	{
		layout = wibox.container.background,
		bg     = beautiful.transparent,
		fg     = '#FFFFFFB0',
		title,
	},
	{
		layout = wibox.container.background,
		bg     = beautiful.transparent,
		fg     = beautiful.fg_soft,
		artist
	}
}

song_date.artist = artist
song_date.title = title
song_date.dates = dates

return song_date

local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local slider    = require 'widget.slider'

local sound_slider = slider(
	'Sound',
	beautiful.icon_sound_soft,
	beautiful.icon_sound,
	require 'widget.sound.slider',
	_G.preferences.manager_sound
)

local brightness_slider = slider(
	'Brightness',
	beautiful.icon_brightness_soft,
	beautiful.icon_brightness,
	require 'widget.brightness.slider'
)

local center = wibox.widget {
	min_cols_size = dpi(5),
	min_rows_size = dpi(5),
	spacing       = dpi(10),
	homogeneous   = false,
	expand        = true,
	layout        = wibox.layout.grid
}

center:add_widget_at(require 'widget.network.networks',  1, 1, 2, 5 )
center:add_widget_at(require 'widget.dont-disturb',      1, 6, 1, 2 )
center:add_widget_at(require 'widget.modes',             2, 6, 1, 1 )
center:add_widget_at(require 'widget.screenshot',        2, 7, 1, 1 )
center:add_widget_at(sound_slider,                       3, 1, 1, 7 )
center:add_widget_at(brightness_slider,                  4, 1, 1, 7 )
center:add_widget_at(require 'widget.music-player',      5, 1, 1, 7 )

return center

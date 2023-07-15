local wibox = require('wibox')
local abutton = require('awful.button')
local aspawn = require('awful.spawn')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local settings = require('settings')
local utils = require('widgets.sound.utils')

return function(s)
	if settings.volumen_indicator then
		require('widgets.sound.tooltip')(s)
	end

	local widget = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(5),
		forced_height = dpi(100),
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(5),
			forced_height = dpi(50),
			{
				widget = wibox.widget.textbox,
				text = 'Sound',
				font = beautiful.font_bold
			},
			require('widgets.sound.slider')
		},
		{
			widget = wibox.widget.separator,
			forced_height = dpi(1),
		},
		{
			widget = wibox.widget.textbox,
			text = 'Sound Preferences',
			buttons = {
				abutton({}, 1, function ()
					aspawn(settings.manager_sound)
				end)
			}
		}
	}

	utils.get_volume(function(volume)
		awesome.emit_signal('sound::level', volume..'%', _, true)
	end)

	return widget
end

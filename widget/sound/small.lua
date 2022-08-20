local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local utils = require('widget.sound.utils')

return function(s)
	if _G.settings.volumen_indicator then
		require('widget.sound.tooltip')(s)
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
			require 'widget.sound.slider'
		},
		{
			widget = wibox.widget.separator,
			forced_height = dpi(1),
		},
		{
			widget = wibox.widget.textbox,
			text = 'Sound Preferences'
		}
	}

	utils.get_volume(function(volume)
		awesome.emit_signal('sound::level', volume..'%', _, true)
	end)

	return widget
end

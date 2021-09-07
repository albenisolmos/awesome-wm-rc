local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

return wibox.widget {
	layout = wibox.container.background,
	bg = beautiful.bg_card,
	shape = shape.rounded_rect,
	forced_height = dpi(60),
	{
		layout = wibox.container.margin,
		left = dpi(10),
		right = dpi(10),
		{
			layout = wibox.layout.flex.vertical,
			require 'widget.network.wifi',
			require 'widget.network.tethering',
			require 'widget.network.bluetooth'
		}
	}
}

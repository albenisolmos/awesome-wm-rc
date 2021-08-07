local shape     = require('gears.shape')
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi

return wibox.widget {
	layout = wibox.container.place,
	{
		widget = wibox.widget.textbox,
		text = 'Wow, such empty',
		font = 'SF Display Regular 20'
	}
}

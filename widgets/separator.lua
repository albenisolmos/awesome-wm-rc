local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

return wibox.widget {
	layout = wibox.container.margin,
	top    = dpi(8),
	bottom = dpi(8),
	{
		image   = beautiful.icon_separator,
		resize  = true,
		widget  = wibox.widget.imagebox
	}
}

local wibox            = require('wibox')
local dpi              = require('beautiful').xresources.apply_dpi

return wibox.widget {
	layout = wibox.layout.align.vertical,
	expand = 'none',
	forced_width = dpi(220),
	nil,
	{
		widget              = wibox.widget.slider,
		id                  = 'brightness_slider',
		value               = 80,
		maximum             = 100
	},
	nil
}

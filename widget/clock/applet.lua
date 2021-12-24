local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local applet = require('widget.applet')

local clock = applet(
	wibox.widget.textclock('%a %d  %l:%M %p'),
	require 'widget.clock.large'
)

clock:set_forced_width(dpi(110))

return clock

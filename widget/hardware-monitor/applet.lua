local wibox            = require('wibox')
local beautiful        = require('beautiful')
local applet           = require 'widget.applet'

return applet(
	wibox.widget.imagebox(beautiful.icon_ram),
	require 'widget.hardware-monitor'
)

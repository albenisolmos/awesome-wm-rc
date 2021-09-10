local wibox        = require('wibox')
local beautiful    = require('beautiful')
local applet = require 'widget.applet'

return applet(
	wibox.widget.imagebox(beautiful.icon_center),
	require 'widget.center'
)

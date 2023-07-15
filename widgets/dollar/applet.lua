local wibox = require('wibox')
local beautiful = require('beautiful')
local applet = require('widgets.applet')

return applet(
	wibox.widget.imagebox(beautiful.icon_dollar),
	require 'widgets.dollar.small'
)

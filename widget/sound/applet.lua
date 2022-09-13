local wibox = require('wibox')
local spawn = require('awful.spawn')
local beautiful = require('beautiful')
local build_applet = require 'widget.applet'

return function(s)
	local widget_medium = require 'widget.sound.small'(s)

	local applet = build_applet(
		wibox.widget.imagebox(beautiful.icon_sound),
		widget_medium,
		function() spawn(SETTINGS.manager_sound) end
	)

	return applet
end

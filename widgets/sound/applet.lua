local wibox = require('wibox')
local spawn = require('awful.spawn')
local beautiful = require('beautiful')
local applet = require('widgets.applet')

return function(s)
	local widget_medium = require 'widgets.sound.small'(s)

	local self = applet(
		wibox.widget.imagebox(beautiful.icon_sound),
		widget_medium,
		function() spawn(SETTINGS.manager_sound) end
	)

	return self
end

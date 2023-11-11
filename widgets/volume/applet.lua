local wibox = require('wibox')
local spawn = require('awful.spawn')
local beautiful = require('beautiful')
local applet = require('widgets.applet')
local settings = require('settings')

return function(s)
	local widget_medium = require 'widgets.volume.small'(s)

	local self = applet(
		wibox.widget.imagebox(beautiful.icon_sound),
		widget_medium,
		function() spawn(settings.manager_sound) end
	)

	return self
end

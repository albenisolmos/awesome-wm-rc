local wibox = require('wibox')
local spawn = require('awful.spawn')
local beautiful = require('beautiful')

local build_applet = require 'widget.applet'
local widget_medium = require 'widget.sound.small'
local volume

local applet = build_applet(
	wibox.widget.imagebox(beautiful.icon_sound),
	widget_medium,
	function() spawn(_G.preferences.manager_sound) end
)

applet:connect_signal('mouse::enter', function()
	spawn.easy_async_with_shell([[bash -c "amixer -D pulse sget Master"]],
	function(stdout)
		volume = tonumber(string.match(stdout, '(%d?%d?%d)%%'))
	end)
end)

return applet

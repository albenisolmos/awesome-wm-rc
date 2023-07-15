local wibox        = require('wibox')
local spawn        = require('awful.spawn')
local beautiful    = require('beautiful')
local app          = require 'apps'
local widget_large = require 'widget.network.wifi.large'
local build_applet = require 'widget.applet'

local applet = build_applet(
	wibox.widget.imagebox(beautiful.icon_wifi_off),
	widget_large,
	function() spawn(app.network_manager, false) end
)

awesome.connect_signal('wifi::update', function(essid)
	if essid then
		applet:set_image(beautiful.icon_wifi_on)
	else
		applet:set_image(beautiful.icon_wifi_off)
	end
end)

return applet

local wibox               = require('wibox')
local beautiful           = require('beautiful')
local dpi                 = beautiful.xresources.apply_dpi
local build_applet        = require 'widget.applet'

local systray = wibox.widget.systray()
systray.visible = false

local applet = build_applet(wibox.widget.imagebox(beautiful.icon_arrow_left), function()
	if systray.visible then
		systray.visible = false
		applet:set_image( beautiful.icon_left_arrow )
	else
		systray.visible = true
		applet:set_image( beautiful.icon_right_arrow )
	end
end,
function() return end)

return wibox.widget {
	layout = wibox.layout.fixed.horizontal,
	systray,
	applet
}

local wibox               = require('wibox')
local beautiful           = require('beautiful')
local build_applet        = require 'widget.applet'

local systray = wibox.widget.systray()
systray.visible = false

local applet = build_applet(
	wibox.widget.imagebox(beautiful.icon_arrow_left),
	function(self)
		if systray.visible then
			systray.visible = false
			self:set_image(beautiful.icon_arrow_left)
		else
			systray.visible = true
			self:set_image(beautiful.icon_arrow_right)
		end
	end
)

return wibox.widget {
	layout = wibox.layout.fixed.horizontal,
	systray,
	applet
}

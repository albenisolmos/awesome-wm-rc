local wibox        = require('wibox')
local beautiful    = require('beautiful')
local dpi          = beautiful.xresources.apply_dpi
local build_applet = require 'widget.applet'

return build_applet(wibox.widget.imagebox(beautiful.icon_center), require 'widget.center')

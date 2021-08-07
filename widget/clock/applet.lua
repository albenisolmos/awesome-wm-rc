local awful     = require('awful')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local build_applet = require('widget.applet')

local clock = build_applet(wibox.widget.textclock('%a %d  %l:%M %p'),
require 'widget.clock.large', function() return end)

clock:set_forced_width(dpi(110))

return clock

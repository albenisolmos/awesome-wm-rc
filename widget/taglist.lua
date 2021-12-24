local wibox  = require('wibox')
local tag  = require('awful.tag')
local widget = require('awful.widget')
local gtable = require('gears.table')
local button = require('awful.button')
local applet = require 'widget.applet'

return function(screen)
	local taglist = applet(widget.taglist {
		screen = screen,
		filter = widget.taglist.filter.selected,
		widget_template = {
			widget = wibox.widget.imagebox,
			buttons = gtable.join(
				button({ }, 1, function(t) tag.viewprev(t.screen) end),
				button({ }, 3, function(t) tag.viewnext(t.screen) end)
			),
			id = 'icon_role'
		}
	})

	return taglist
end

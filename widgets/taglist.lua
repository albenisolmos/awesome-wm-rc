local wibox  = require('wibox')
local tag  = require('awful.tag')
local widget = require('awful.widget')
local gtable = require('gears.table')
local ascreen = require('awful.screen')
local button = require('awful.button')
local applet = require 'widgets.applet'

return function(screen)
	local taglist = applet(widget.taglist {
		screen = screen,
		filter = widget.taglist.filter.selected,
		widget_template = {
			id = 'icon_role',
			widget = wibox.widget.imagebox,
		}
	})

	taglist.buttons = gtable.join(
		button {
			modifiers = {},
			button = 1,
			on_press  = function(t)
				tag.viewprev(t.screen)
			end
		},
		button {
			modifiers = {},
			button = 3,
			on_press  = function(t)
				tag.viewnext(t.screen)
			end
		}
	)

	return taglist
end

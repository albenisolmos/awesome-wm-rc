local wibox  = require('wibox')
local awful  = require('awful')
local applet = require 'widget.applet'

return function(screen)
	local taglist = applet(awful.widget.taglist {
		screen = screen,
		filter = awful.widget.taglist.filter.selected,
		widget_template = {
			widget = wibox.widget.imagebox,
			id = 'icon_role'
		}
	})

	taglist.buttons = {
		awful.button({ }, 1, function(t) awful.tag.viewprev(t.screen) end),
		awful.button({ }, 3, function(t) awful.tag.viewnext(t.screen) end),
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end)
	}

	return taglist
end

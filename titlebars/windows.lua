local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi

awful.titlebar.enable_tooltip = false

local function on_drag_client_to_edge()
	if mouse.coords.y == screen.focused.geometry.y then
		notif('TOP')
	end
end

client.connect_signal('request::titlebars', function(c)
	local titlebar_buttons = {
		awful.button({ }, 1, function()
			c:activate {
				context = 'titlebar',
				action = 'mouse_move'
			}
		end),
		awful.button({ }, 3, function()
			c:activate {
				context = 'titlebar',
				action = 'mouse_resize'
			}
		end)
	}

	local buttons = wibox.layout.fixed.horizontal()

	if c.type == 'dialog' then
		buttons:add(awful.titlebar.widget.closebutton(c))
		goto continue
	end

	buttons:add(awful.titlebar.widget.minimizebutton(c))
	buttons:add(awful.titlebar.widget.maximizedbutton(c))
	buttons:add(awful.titlebar.widget.closebutton(c))

	::continue::

	awful.titlebar(c,{ size = 35 }).widget = {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.container.margin,
			left   = dpi(10),
			right  = dpi(10),
			top    = dpi(10),
			bottom = dpi(10),
			awful.titlebar.widget.iconwidget(c)
		},
		{
			widget = awful.titlebar.widget.titlewidget(c),
			align = 'left',
			font = "Ubuntu 10.3",
			buttons = titlebar_buttons
		},
		buttons
	}
end)

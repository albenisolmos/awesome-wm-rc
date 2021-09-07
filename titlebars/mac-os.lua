local awful = require('awful')
local abutton = require('awful.button')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi

awful.titlebar.enable_tooltip = false

client.connect_signal('request::titlebars', function(c)
	local buttons = wibox.layout.fixed.horizontal()
	buttons:set_spacing(8)

	if c.type == 'dialog' then
		buttons:add(awful.titlebar.widget.closebutton(c))
	else
		buttons:add(awful.titlebar.widget.minimizebutton(c))
		buttons:add(awful.titlebar.widget.maximizedbutton(c))
		buttons:add(awful.titlebar.widget.closebutton(c))
	end

	awful.titlebar(c, {size = 35}).widget = {
		layout = wibox.layout.align.horizontal,
		nil,
		{
			widget = awful.titlebar.widget.titlewidget(c),
			align = 'center',
			font = "Ubuntu 10.3",
			buttons = {
				abutton({ }, 1, function()
					c:activate {
						context = 'titlebar',
						action = 'mouse_move'
					}
				end),
				abutton({ }, 3, function()
					c:activate {
						context = 'titlebar',
						action = 'mouse_resize'
					}
				end)
			}
		},
		{
			layout  = wibox.container.margin,
			top     = dpi(9),
			bottom  = dpi(9),
			right   = dpi(10),
			buttons
		}
	}
end)

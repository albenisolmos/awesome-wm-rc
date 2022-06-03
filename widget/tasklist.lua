local amenu = require('awful.menu')
local abutton = require('awful.button')
local wibox = require('wibox')
local gshape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gtable = require('gears.table')
local awidget = require('awful.widget')
local clickable = require('widget.clickable')
local applet = require('widget.applet')
local uclient = require('utils.client')

local selected_client

local options = amenu {
	items = {
		{ 'Close', function()
			selected_client:kill()
		end},
		{ 'Maximize', function()
				selected_client.maximized = not selected_client.maximized
		end },
		{ 'Iconify', function()
				selected_client.minimized = not selected_client.minimized
			end},
		{ 'On top', function()
				selected_client.ontop = not selected_client.ontop
		end},
		{ 'Sticky', function()
				selected_client.sticky = not selected_client.sticky
		end},
	}
}

return function(screen)
	local tasklist = awidget.tasklist {
		source = uclient.get_clients,
		base_widget = wibox.layout.fixed.horizontal,
		screen = screen,
		filter = awidget.tasklist.filter.currenttags,
		buttons = gtable.join(
			abutton({ }, 1, function(c)
				if c == client.focus then
					c.minimized = true
				else
					c.minimized = false
					if not c:isvisible() and c.first_tag then
						c.first_tag:view_only()
					end
					client.focus = c
					c:raise()
				end
			end),
			abutton({}, 2, function(c)
				c:kill()
			end),
			abutton({ }, 3, function()
				options:toggle()
			end),
			abutton({ }, 4, function(c)
				c.width = c.width + 5
				c.height = c.height + 5
			end),
			abutton({ }, 5, function(c)
				c.width = c.width - 5
				c.height = c.height - 5
			end)
		),
		style = {
			shape_focus = function(cr, width, height, radius) 
				gshape.rounded_rect(cr, width, height, 3)
			end,
			shape = function(cr, width, height, radius) 
				gshape.rounded_rect(cr, width, height, 3)
			end,
			fg_normal = '#999999'
		},
		widget_template = {
			id = 'background_role',
			layout = clickable,
			create_callback = function(self, c, index)
				self.client = c
				self:get_children_by_id('background_role')[1]:connect_signal('mouse::enter', function()
					selected_client = c
				end)
			end,
			{
				layout = wibox.layout.fixed.horizontal,
				{
					layout = wibox.container.margin,
					margins = dpi(3),
					{
						id = 'icon_role',
						widget = wibox.widget.imagebox
					}
				},
				{
					widget = wibox.widget.textbox,
					id = 'text_role'
				}
			}
		}
	}
	tasklist.visible = true 

	local tasklist_layout = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		fill_space = true,
		applet(wibox.widget.imagebox(beautiful.icon_list),
			function()
				tasklist.visible = not tasklist.visible
				tasklist:emit_signal('widget::redraw_needed')
			end),
		tasklist,
		nil
	}

	return tasklist_layout
end

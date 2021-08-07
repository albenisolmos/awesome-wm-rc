local awful               = require('awful')
local abutton             = require('awful.button')
local wibox               = require('wibox')
local gears               = require('gears')
local gshape               = require('gears.shape')
local beautiful           = require('beautiful')
local dpi                 = beautiful.xresources.apply_dpi
local clickable           = require 'widget.clickable'
local applet              = require 'widget.applet'

local function notif(str) awesome.emit_signal('notif', str) end
local selected_client;

local options = awful.menu {
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
	local tasklist = awful.widget.tasklist {
		screen = screen,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = {
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
			abutton({ }, 3, function(c)
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
		},
		style = {
			shape_focus = function(cr, width, height, radius) 
				gshape.rounded_rect(cr, width, height, 3)
			end,
			shape = function(cr, width, height, radius) 
				gshape.rounded_rect(cr, width, height, 3)
			end,
			fg_normal = '#999999'
		},
		--[[layout {
			layout = wibox.layout.fixed.horizontal,
			fill_space = true,
		},]]
		widget_template = {
			id = 'background_role',
			layout = clickable,
			on_enter = function(self)
				notif(self.client or 'loc')
			end,
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
				}
			}
		}
	}
	tasklist.visible = false

	local tasklist_applet = applet(
	wibox.widget.imagebox(beautiful.icon_list),
	function()
		if tasklist.visible then
			tasklist.visible = false
		else
			tasklist.visible = true 
		end
		tasklist:emit_signal('widget::redraw_needed')
	end,
	function() end)

	local tasklist_layout = wibox.widget {
		layout = wibox.layout.align.horizontal,
		tasklist_applet,
		{
			layout = wibox.layout.fixed.horizontal,
			tasklist
		}
	}

	return tasklist_layout
end

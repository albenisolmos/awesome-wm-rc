local amenu = require('awful.menu')
local amouse = require('awful.mouse')
local abutton = require('awful.button')
local wibox = require('wibox')
local gshape = require('gears.shape')
local gtimer = require('gears.timer')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gtable = require('gears.table')
local awidget = require('awful.widget')
local clickable = require('widgets.clickable')
local applet = require('widgets.applet')
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

-- local function test(cli)
	-- 	printn(cli.type)
	-- 	if cli.type == 'dnd' then
	-- 		printn('dnd')
	-- 	end
	-- end
	-- 
	-- amouse.resize.add_leave_callback(test, 'mouse.move')

	local timer_focus_client = gtimer {
		timeout = 1,
		autostart = false,
		single_shot = true,
		callback = function()
			client.focus = selected_client
		end
	}

	local block_enter_event = false
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
					local bg = self:get_children_by_id('background_role')[1]

					bg:connect_signal('mouse::enter', function()
						if block_enter_event then
							return
						end
						block_enter_event = true

						selected_client = c
						if amouse.is_left_mouse_button_pressed then
							timer_focus_client:start()
						end
					end)

					bg:connect_signal('mouse::leave', function()
						block_enter_event = false
						if amouse.is_left_mouse_button_pressed then
							timer_focus_client:stop()
						end
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

		local tasklist_layout = tasklist
		--local tasklist_layout = wibox.widget {
		--	layout = wibox.layout.flex.horizontal,
		--	fill_space = false,
		--	applet(wibox.widget.imagebox(beautiful.icon_list),
		--	function()
		--		tasklist.visible = not tasklist.visible
		--		tasklist:emit_signal('widget::redraw_needed')
		--	end),
		--	tasklist,
		--}

		return tasklist_layout
	end

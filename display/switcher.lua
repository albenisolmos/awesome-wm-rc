local awful = require('awful')
local wibox = require('wibox')
local shape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local index, past_index, max_index, index_client_focus, clients_list_children

function notif(message)
	awesome.emit_signal('notif', message)
end

local build_widget_client = function(c)
	local client_widget = wibox.widget {
		layout        = wibox.layout.fixed.vertical,
		spacing       = dpi(5),
		forced_height = dpi(120),
		forced_width  = dpi(120),
		client        = c,
		{
			layout        = wibox.container.background,
			bg            = beautiful.transparent,
			shape         = shape.rounded_rect,
			forced_height = dpi(80),
			forced_width  = dpi(80),
			id            = 'bg',
			{
				layout = wibox.container.place,
				wibox.widget.imagebox(c.icon)
			}
		},
		{
			layout = wibox.container.place,
			{
				layout = wibox.container.background,
				fg     = beautiful.transparent,
				id     = 'text',
				wibox.widget.textbox(c.name)
			}
		}
	}

	local fg = beautiful.transparent
	local bg = client_widget:get_children_by_id('bg')[1]
	local text = client_widget:get_children_by_id('text')[1]

	if client.focus == c then
		bg:set_bg(beautiful.bg_chips)
		text:set_fg(beautiful.fg_soft_focus)
	end

	function client_widget:set_focus(focus)
		if focus then
			bg:set_bg(beautiful.bg_chips)
			text:set_fg(beautiful.fg_soft_focus)
		else
			bg:set_bg(beautiful.transparent)
			text:set_fg(fg)
		end
	end

	return client_widget
end

local clients_list = wibox.layout.fixed.horizontal()

function clients_list:update()
	self:reset()
	local clients = awful.screen.focused().selected_tag:clients()
	local i = 0
	local testc, lastc

	for _, c in pairs(clients) do
		i = i + 1

		if c.minimized or c.skip_taskbar then
			i = i - 1
			goto continue
		elseif c == client.focus then
			index_client_focus = i
		end

		self:add(build_widget_client(c))
		max_index = i

		::continue::
	end

	collectgarbage('collect')
end

return function(screen)
	local switcher = wibox {
		screen  = screen,
		ontop   = true,
		visible = false,
		bg      = beautiful.bg,
		shape   = shape.rounded_rect,
		widget  = wibox.container.margin(clients_list, dpi(15), dpi(15), dpi(15), 0)
	}

	local function update_geometry()
		switcher.width, switcher.height = wibox.widget.base.fit_widget(
		clients_list,
		{ dpi = screen.dpi or beautiful.xresources.get_dpi() },
		clients_list,
		1000, 200)
		switcher.x = (screen.geometry.width - switcher.width)/2
		switcher.y = (screen.geometry.height - switcher.height)/2
	end

	awful.keygrabber {
		keybindings = {
			awful.key {
				modifiers = {'Mod4'},
				key       = 'Tab',
				on_press  = function()
					past_index = index
					index = index + 1

					if index > max_index then
						past_index = max_index
						index = 1
					end

					clients_list_children[past_index]:set_focus(false)
					clients_list_children[index]:set_focus(true)
				end
			},
			awful.key {
				modifiers = {'Mod4', 'Shift'},
				key       = 'Tab',
				on_press  = function()
					past_index = index
					index = index - 1

					if index < 1 then
						past_index = 1
						index = max_index
					end

					clients_list_children[past_index]:set_focus(false)
					clients_list_children[index]:set_focus(true)
				end
			}
			--[[awful.key {
				modifiers = {'Mod4'},
				key       = 'x',
				on_press  = function()
					clients_list_children[index].client:kill()
					clients_list:remove(index)
					clients_list:update()
					update_geometry()
					clients_list_children[past_index]:set_focus(true)
					index = index - 1
				end
			}]]
		},
		stop_key           = 'Mod4',
		stop_event         = 'release',
		start_callback     = function()
			-- Update client list
			clients_list:update()
			clients_list_children = clients_list.children

			update_geometry()

			switcher.visible = true
			index = index_client_focus
		end,
		stop_callback      = function()
			switcher.visible = false
			clients_list_children[index].client:activate { raise = true }
		end,
		export_keybindings = true,
	}
end

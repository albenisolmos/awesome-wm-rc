local awful = require('awful')
local wibox = require('wibox')
local shape = require('gears.shape')
local gears = require('gears')
local beautiful = require('beautiful')
local naughty = require('naughty')
local dpi = beautiful.xresources.apply_dpi

local clients_box = wibox.layout.fixed.horizontal()
local first_time = true
local index = 1, past_index, max_index
local index_client_focus = 1 
local clients_box_children
local clients

local function update_clients()
	clients = awful.screen.focused().selected_tag:clients()
end

client.connect_signal('property::minimized', update_clients)
client.connect_signal('unmanage', update_clients)
client.connect_signal('manage', update_clients)
screen.connect_signal('tag::history::update', update_clients)

local build_widget_client = function(c)
	if not c then error('No client provided') end
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

local function swap_last_widget()
	local index_last_client = index_client_focus-1
	if index_last_client < 1 then index_last_client = max_index end
	clients_box:swap(index_last_client, index_client_focus)
end

function clients_box:update()
	self:reset()
	local i = 0

	for _, c in pairs(clients) do
		i = i + 1

		if c.minimized or c.skip_taskbar then
			i = i - 1
			goto continue
		elseif c == client.focus then
			index_client_focus = i
		end

		max_index = i
		self:add(build_widget_client(c))
		::continue::
	end

	clients_box_children = self.children
	--collectgarbage('collect')
	swap_last_widget()
end

return function(screen)
	local switcher = wibox {
		screen  = screen,
		ontop   = true,
		visible = false,
		bg      = beautiful.bg,
		shape   = shape.rounded_rect,
		widget  = wibox.container.margin(clients_box, dpi(15), dpi(15), dpi(15), 0)
	}

	function switcher:update_geometry()
		self.width, self.height = wibox.widget.base.fit_widget(
			clients_box,
			{ dpi = screen.dpi or beautiful.xresources.get_dpi() },
			clients_box,
			screen.geometry.width, 200
		)
		self.x = (screen.geometry.width - self.width)/2
		self.y = (screen.geometry.height - self.height)/2
	end

	awful.keygrabber {
		keybindings = {
			awful.key {
				modifiers = {'Mod4'},
				key       = 'Tab',
				on_press  = function()
					if #clients <= 1 then
						return
					elseif first_time then
						first_time = false
						clients_box_children[index]:set_focus(true)
						return
					end
					past_index = index
					index = index + 1

					if index > max_index then
						past_index = max_index
						index = 1
					end

					clients_box_children[past_index]:set_focus(false)
					clients_box_children[index]:set_focus(true)
				end
			},
			awful.key {
				modifiers = {'Mod4', 'Shift'},
				key       = 'Tab',
				on_press  = function()
					if #clients <= 1 then return end
					past_index = index
					index = index - 1

					if index < 1 then
						past_index = 1
						index = max_index
					end

					clients_box_children[past_index]:set_focus(false)
					clients_box_children[index]:set_focus(true)
				end
			}
		},
		stop_key       = 'Mod4',
		stop_event     = 'release',
		start_callback = function()
			if #clients == 0 then return end
			clients_box:update()
			switcher:update_geometry()
			first_time = true 
			switcher.visible = true
		end,
		stop_callback = function()
			if #clients == 0 then return end
			switcher.visible = false
			clients_box_children[index].client:activate { raise = true }
		end,
		export_keybindings = true
	}

	return switcher
end

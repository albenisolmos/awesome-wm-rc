local unpack = table.unpack or unpack

local ascreen = require('awful.screen')
local akeygrabber = require('awful.keygrabber')
local wibox = require('wibox')
local shape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local client_widget = require 'display.switcher.client-widget'
local clients_box = wibox.layout.fixed.horizontal()
local clients = {}
local index = 1
local switcher = {}
local last_client

local function get_client_widget(idx)
	local widget = clients_box.children[idx]
	return widget and widget or clients_box.children[1] or {}
end

local function client_can_be_shown(c)
	 return not (c.minimized or c.skip_taskbar or c.hidden)
end

local function filter_clients(clis)
	for i, cli in pairs(clis) do
		if not client_can_be_shown(cli) then
			table.remove(clis, i)
		end
	end

	return clis
end

local function update_clients()
	local tag = ascreen.focused().selected_tag
	clients = filter_clients(tag:clients())
end

local function increase_index()
	index = index + 1 > #clients_box.children and 1 or index + 1
end

local function decrease_index()
	index = index - 1 < 1 and #clients_box.children or index - 1
end

local function remove_client(c)
	if client_can_be_shown(c) then
		for i, child in pairs(clients_box.children) do
			if child.client == c then
				clients_box:remove(i)
				switcher:update_geometry()
				clients_box:emit_signal('widget::redraw_needed')
				clients_box:emit_signal('widget::layout_changed')
				break
			end
		end
	end
end

local function add_client(c)
	if last_client == c then return end
	if client_can_be_shown(c) then
		clients_box:add(client_widget(c))
		switcher:update_geometry()
	end
end

local function add_clients(clis)
	last_client = clis[1]
	for _, cli in pairs(clis) do
		if client_can_be_shown(cli) then
			clients_box:add(client_widget(cli))
		end
	end
	switcher:update_geometry()
end

local function change_clients(clis)
	for i, widget in pairs(clients_box.children) do
		widget:change_client(clis[i])
		widget:emit_signal('widget::redraw_needed')
		widget:emit_signal('widget::layout_changed')
	end
end

local function remove_clients(amount)
	for i=1, amount do
		table.remove(clients_box.children, i)
	end

	clients_box:emit_signal('widget::redraw_needed')
	clients_box:emit_signal('widget::layout_changed')
end

local function recycle_clients()
	local n_clients = #clients
	local n_clients_widgets = #clients_box.children

	if n_clients < 1 then
		return
	elseif n_clients_widgets == 0 and n_clients > 0 then
		add_clients(clients)
	elseif n_clients == n_clients_widgets then
		change_clients(clients)
	elseif n_clients > n_clients_widgets then
		change_clients(clients)
		add_clients({unpack(clients, n_clients_widgets+1, n_clients)})
	elseif n_clients < n_clients_widgets then
		remove_clients(n_clients_widgets-n_clients)
		change_clients(clients)
	end

	switcher:update_geometry()
end

local function focus_next_client(no_change_prev)
	local n_clients = #clients

	if n_clients < 1 then
		return
	elseif no_change_prev ~= true then
		get_client_widget(index):focus(false)
	end

	increase_index()
	get_client_widget(index):focus(true)
end

local function focus_previous_client()
	if #clients < 1 then return end

	get_client_widget(index):focus(false)
	decrease_index()
	get_client_widget(index):focus(true)
end

local function close_focused_client()
	get_client_widget(index).client:kill()
	focus_next_client(true)
end

local function minimize_focused_client()
	get_client_widget(index).client.minimized = true
	focus_next_client(true)
end

client.connect_signal('manage', function(cli)
	update_clients()
	add_client(cli)
end)
client.connect_signal('unmanage', function(cli)
	update_clients()
	remove_client(cli)
end)
client.connect_signal('property::minimized', function(cli)
	update_clients()
	remove_client(cli)
end)
--client.connect_signal('tagged', update_clients)
screen.connect_signal('tag::history::update', function()
	update_clients()
	recycle_clients()
end)

return function(screen)
	local widget_margin = wibox.container.margin(
		clients_box, dpi(15), dpi(15), dpi(15), 0
	)
	switcher = wibox {
		screen  = screen,
		ontop   = true,
		visible = false,
		bg      = beautiful.bg,
		shape   = shape.rounded_rect,
		widget  = widget_margin
	}

	function switcher:update_geometry()
		if #clients < 1 then
			self.visible = false
			return
		end

		self.width, self.height = wibox.widget.base.fit_widget(
			widget_margin,
			{ dpi = screen.dpi or beautiful.xresources.get_dpi() },
			clients_box,
			screen.geometry.width, 200
		)

		self.x = (screen.geometry.width - self.width)/2
		self.y = (screen.geometry.height - self.height)/2
	end

	akeygrabber {
		root_keybindings = {
			{{'Mod4'}, 'Tab', function()
					if #clients > 0 then
						get_client_widget(index):focus(true)
					end
				end
			}
		},
		keybindings = {
				{{'Mod4'}, 'Tab', focus_next_client},
				{{'Mod4', 'Shift'}, 'Tab', focus_previous_client},
				{{'Mod4'}, 'x', close_focused_client},
				{{'Mod4'}, 's', minimize_focused_client}
		},
		stop_key = 'Mod4',
		stop_event = 'release',
		start_callback = function()
			if #clients < 1 then return end
			switcher.visible = true
		end,
		stop_callback = function()
			switcher.visible = false
			if #clients <= 1 then return end

			local children = clients_box.children
			local c = children[index].client
			client.focus = c
			c:raise()
			children[index]:focus(false)
		end,
		export_keybindings = false
	}

	return switcher
end

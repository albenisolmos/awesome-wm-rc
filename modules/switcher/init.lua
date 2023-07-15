local wibox = require('wibox')
local akeygrabber = require('awful.keygrabber')
local akey = require('awful.key')
local shape = require('gears.shape')
local gtable = require('gears.table')
local ascreen = require('awful.screen')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local settings = require('settings')
local uclient = require('utils.client')

local client_widget = require('modules.switcher.client-widget')
local clients_box = wibox.layout.fixed.horizontal()
local clients = {}
local switcher = {}
local index = 1
local last_client
local modkey = settings.modkey
local grabber_started
local keygrabber = {}
local M = {}

local function get_client_widget(idx)
	local widget = clients_box.children[idx] or clients_box.children[1]
	if not widget then
		printn('get_client_widget: widget is null in the index ' .. idx )
	end
	return widget or {}
end

local function update_clients()
	clients = uclient.get_clients(function(cli)
		return uclient.is_displayable(cli)
	end)
end

local function increase_index()
	index = index + 1 > #clients_box.children and 1 or index + 1
end

local function decrease_index()
	index = index - 1 < 1 and #clients_box.children or index - 1
end

local function switcher_update_geometry()
	if #clients < 1 then
		switcher.visible = false
		return
	end

	local screen = ascreen.focused()

	switcher.width, switcher.height = wibox.widget.base.fit_widget(
	switcher.widget,
	{ dpi = screen.dpi or beautiful.xresources.get_dpi() },
	clients_box,
	screen.geometry.width, 200
	)

	switcher.x = (screen.geometry.width - switcher.width)/2
	switcher.y = (screen.geometry.height - switcher.height)/2
end

local function remove_client(cli, force)
	if not uclient.is_displayable(cli) and not force then
		return
	elseif type(cli) == 'number' then
		clients_box:remove(cli)
		return
	end

	for i, child in pairs(clients_box.children) do
		if child.client == cli then
			clients_box:remove(i)
			switcher_update_geometry()
			break
		end
	end
end

local function remove_clients(amount)
	for i=1, amount do
		clients_box:remove(i)
	end
	clients_box:emit_signal('widget::redraw_needed')
	clients_box:emit_signal('widget::layout_changed')
end

local function switcher_finish()
	if not grabber_started then return end
	switcher.visible = false
	if #clients <= 1 then return end

	local children = clients_box.children
	local cli = children[index].client

	client.focus = cli
	cli:raise()
	children[index]:focus(false)

	grabber_started = false
	keygrabber:stop()
end

local function switcher_start()
	grabber_started = true

	if #clients > 0 then
		get_client_widget(index):focus(true)
		switcher.visible = true
	end

	keygrabber:start()
end

local function switcher_add_client(cli)
	if last_client == cli or not uclient.is_displayable(cli) then
		return
	end

	clients_box:add(client_widget(cli))
	switcher_update_geometry()
	clients_box:emit_signal('widget::redraw_needed')
	clients_box:emit_signal('widget::layout_changed')
end

local function switcher_add_clients(clis)
	last_client = clis[1]
	for _, cli in pairs(clis) do
		if uclient.is_displayable(cli) then
			clients_box:add(client_widget(cli))
		end
	end
	switcher_update_geometry()
end

local function change_clients(clis)
	for i, widget in pairs(clients_box.children) do
		widget:change_client(clis[i])
		widget:emit_signal('widget::redraw_needed')
		widget:emit_signal('widget::layout_changed')
	end
end

local function recycle_clients()
	local n_clients = #clients
	local n_clients_widgets = #clients_box.children

	if n_clients < 1 and n_clients_widgets > 0 then
		remove_clients(n_clients_widgets)
		return
	elseif n_clients_widgets == 0 and n_clients > 0 then
		switcher_add_clients(clients)
	elseif n_clients == n_clients_widgets then
		change_clients(clients)
	elseif n_clients > n_clients_widgets then
		change_clients(clients)
		switcher_add_clients({unpack(clients, n_clients_widgets+1, n_clients)})
	elseif n_clients < n_clients_widgets then
		remove_clients(n_clients_widgets-n_clients)
		change_clients(clients)
	end

	switcher_update_geometry()
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

function M.on_keymaps()
	return gtable.join(akey({modkey}, 'Tab', switcher_start))
end

function M.on_screen(s)
	switcher = wibox {
		screen  = s,
		ontop   = true,
		visible = false,
		bg      = beautiful.wibox_bg,
		shape   = shape.rounded_rect,
        border_width = dpi(settings.client_border_width or 1),
        border_color = beautiful.border_focus,
		widget  = wibox.widget {
			clients_box,
			margins = dpi(10),
			widget = wibox.container.margin
		}
	}

	screen.connect_signal('tag::history::update', function()
		update_clients()
		recycle_clients()
	end)

	client.connect_signal('manage', function(cli)
		update_clients()
		switcher_add_client(cli)
	end)

	client.connect_signal('unmanage', function(cli)
		if not cli then
			printn('unmanage: not client')
		end
		update_clients()
		remove_client(cli)
	end)

	client.connect_signal('property::minimized', function(cli)
		update_clients()
		if cli.minimized then
			remove_client(cli, true)
		else
			switcher_add_client(cli)
		end
	end)

	keygrabber = akeygrabber {
		mask_modkeys = true,
		keybindings = {
			akey {
				modifiers = {modkey},
				key       = 'Tab',
				on_press  = focus_next_client
			},
			akey {
				modifiers = {modkey, 'Shift'},
				key       = 'Tab',
				on_press  = focus_previous_client
			},
			akey {
				modifiers = {modkey},
				key       = 'x',
				on_press  = close_focused_client
			},
			akey {
				modifiers = {modkey},
				key       = 's',
				on_press  = minimize_focused_client
			},
			akey {
				modifiers = {modkey},
				key       = 'd',
				on_press  = function(self)
					self:stop()
				end
			},
		},
		stop_key = modkey,
		stop_event = 'release',
		start_callback = focus_next_client,
		stop_callback = function()
			switcher_finish()
		end
	}
end

return M

local wibox     = require("wibox")
local awful     = require('awful')
local timer     = require('gears.timer')
local shape     = require('gears.shape')
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi

local apps        = require "apps"
local animate     = require 'util.animate'
local thumbnail   = require 'util.thumbnail'
local separator     = require 'widget.separator'

local insert = table.insert
local icon_path = '/usr/share/icons/Papirus/48x48/apps/'
local partial_show = false

local tooltip = awful.tooltip {
	delay_show = 1,
	align = 'top',
	mode = 'outside',
	preferred_alignments = 'middle',
	shape = shape.rounded_rect
}

local function add_item( icon, app, name )
	local icon = wibox.widget.imagebox( icon, true )
	local item = animate.widget.scale( icon, 20 )
	item.name = name or nil

	item:buttons({awful.button({ }, 1, function()
		awful.spawn.raise_or_spawn(app)
	end)})

	item:connect_signal('button::press', function()
		item:scale(15)
	end)

	item:connect_signal('button::release', function()
		item:scale(20)
	end)

	item:connect_signal('mouse::enter', function()
		tooltip:set_text(app)
		item:scale(0)
	end)

	item:connect_signal('mouse::leave', function()
		item:scale(20)
	end)

	tooltip:add_to_object(item)

	return wibox.widget {
		layout = wibox.layout.fixed.vertical,
		item,
	}
end

local items_layout = wibox.layout.fixed.horizontal()
items_layout:set_spacing(dpi(5))
items_layout:add(add_item( beautiful.icon_launcher, apps.launcher ))
items_layout:add(wibox.widget {
		layout = wibox.container.margin,
		top = dpi(4),
		bottom = dpi(4),
		{
			widget = wibox.widget.separator,
			orientation = 'vertical',
			forced_width = dpi(1)
		}
	})
items_layout:add(add_item( beautiful.icon_file_manager, apps.filemanager,  'Nautilus' ))

local function current_clients()
	local t = awful.screen.focused().selected_tag
	return t:clients()
end

local function add_widget_open()
	return wibox.widget {
		layout = wibox.container.background,
		bg     = '#FFFFFF90',
		shape  = shape.circle,
		{
			layout  = wibox.container.margin,
			margins = dpi(2)
		}
	}
end

return function(screen, autohide)
	local normal_coord = screen.geometry.height - dpi(52)
	local offscreen_coord = screen.geometry.height + 1

	local dock = wibox {
		screen  = screen,
		type    = 'dock',
		ontop   = false,
		visible = true,
		height  = dpi(40),
		width   = dpi(1),
		y       = offscreen_coord,
		bg      = beautiful.bg,
		shape   = shape.rounded_rect,
		border_color = beautiful.bg_medium,
		widget  = items_layout
	}

	function dock:hide()
		if self.y == offscreen_coord then return end
		partial_show = false
		self:struts({ bottom = 0 })
		animate.move.y(self, offscreen_coord)
	end

--	dock:struts( { bottom = dpi(48) } )

	function dock:fit()
		local num_items = 0
		for _, item in pairs(items_layout.children) do
			num_items = num_items + 43
		end
		num_items = num_items - 10
		self.width = num_items
		self.x = (screen.geometry.width-self.width) / 2
	end

	local function clients_hide_dock()
		local clients = current_clients()

		for _, client in pairs(clients) do
			if (client.maximized or client.fullscreen) and not client.minimized then
				return true
			end
		end

		return false
	end

	local function get_dock_clients()
		local dock_clients = {}
		for i, item in pairs(items_layout.children) do
			table.insert(dock_clients, { i, item.name })
			awesome.emit_signal('notif', i .. '::' .. (item.name or 'null'))
		end
		return dock_clients
	end

	local function update_dock_clients()
		local dock_clients = get_dock_clients()
		local clients = current_clients()

		for _, client in pairs(clients) do
			for _, dc in pairs(dock_clients) do
				if client == dc[2] then
					items_layout.children[dc[1]]:add(add_widget_open())
				end
			end
		end
	end

	local time_hide_dock = timer {
		timeout = 1,
		autostart = false,
		single_shot = true,
		callback = function()
			dock:hide()
			partial_show = false
		end
	}

	dock:connect_signal('mouse::leave', function()
		if partial_show then
			time_hide_dock:start()
		end
	end)
	dock:connect_signal('mouse::enter', function()
		if time_hide_dock.started then
			time_hide_dock:stop()
		end
	end)

	function dock:show()
		if dock.y == normal_coord then return end
		partial_show = true
		animate.move.y(dock, normal_coord)
		if autohide then
			dock.ontop = true
			time_hide_dock:start()
		else
			dock:struts( { bottom = dpi(48) } )
		end
	end

	awesome.connect_signal('dock::update', function()
		if clients_hide_dock() then
			dock:hide()
		else
			dock:show()
		end
	end)

	awesome.connect_signal('dock::partial_show', function()
		if dock.y == normal_coord then return end
		dock.ontop = true
		partial_show = true
		animate.move.y(dock, normal_coord)
		time_hide_dock:start()
	end)

	local function client_toggle_dock(c)
		if c.maximized or c.fullscreen then
			dock.ontop = true
			dock:hide()
		else
			if clients_hide_dock() then
				return
			else
				dock.ontop = false
				dock:show()
			end
		end
	end

	awesome.connect_signal('dock::item', function(args)
		items_layout:add(add_item(args.icon, args.onclick, args.name))
		dock:fit()
	end)
	client.connect_signal('property::maximized', client_toggle_dock)
	client.connect_signal('property::fullscreen', client_toggle_dock)
	tag.connect_signal('property::layout', function(t)
		local clients = t:clients()
		for _, c in pairs(clients) do
			if not c.floating then
				dock.ontop = true
				dock:hide()
				return
			end
		end
	end)

	update_dock_clients()
	return dock
end

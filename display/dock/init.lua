local wibox     = require("wibox")
local awful     = require('awful')
local timer     = require('gears.timer')
local shape     = require('gears.shape')
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi

local animate    = require 'util.animate'
local build_item = require 'display.dock.item'
local utils      = require 'display.dock.utils'

local partial_show = false

local items_layout = wibox.layout.fixed.horizontal()
items_layout:set_spacing(dpi(5))
items_layout:add(build_item(beautiful.icon_launcher, nil, _G.preferences.launcher))
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

local function current_clients()
	local t = awful.screen.focused().selected_tag
	return t:clients()
end

return function(s)
	local normal_coord = s.geometry.height - dpi(52)
	local offscreen_coord = s.geometry.height + 1

	local dock = wibox {
		screen  = s,
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

	function dock:fit()
		local num_items = 43 * #items_layout.children
		num_items = num_items - 10
		self.width = num_items
		self.x = (s.geometry.width-self.width) / 2
	end

	local function need_hide_dock()
		local clients = current_clients()

		if #clients > 0 then
			for _, client in pairs(clients) do
				if (client.maximized or client.fullscreen) and not client.minimized then
					return true
				end
			end
		end

		return false
	end

	local time_hide_dock = timer {
		timeout = 1,
		autostart = false,
		single_shot = true,
		callback = function()
			dock:hide()
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
		if self.y == normal_coord then return end
		partial_show = true
		animate.move.y(self, normal_coord)
		if _G.preferences.dock_autohide then
			self.ontop = true
			time_hide_dock:start()
		else
			self:struts({ bottom = dpi(48) })
		end
	end

	awesome.connect_signal('dock::update', function()
		if need_hide_dock() then
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
			if need_hide_dock() then
				return
			else
				dock.ontop = false
				dock:show()
			end
		end
	end

	screen.connect_signal('tag::history::update', function()
	end)
	awesome.connect_signal('dock::item', function(args)
		items_layout:add(build_item(args.icon, args.name, args.onclick))
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

	utils.remember_apps();
	return dock
end

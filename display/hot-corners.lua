local wibox     = require('wibox')
local gtimer     = require('gears.timer')
local placement = require('awful.placement')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local hotedge = {mt = {}}

function hotedge.new(args)
	local screen = args.screen
	local props = {
		callback = true,
		timeout = 0.5
	}
	local edge = wibox {
		screen    = screen,
		visible   = true,
		ontop     = true,
		opacity   = 0.0,
		x         = screen.geometry.x,
		y         = screen.geometry.y,
		type      = 'utility',
	}

	if args.position then
		if args.position == 'bottom' or args.position == 'top' then
			edge.height = dpi(3);
			edge.width = screen.geometry.width
		elseif args.position == 'left' or args.position == 'right' then
			edge.height = screen.geometry.height
			edge.width = dpi(3)
		end

		local place = placement[args.position] + placement.center
		place(edge)
	end

	for key, value in pairs(args) do
		if props[key] then
			props[key] = value
		else
			edge[key] = value
		end
	end

	local timer = gtimer {
		timeout   = props.timeout,
		call_now  = false,
		autostart = false,
		callback  = function(self)
			if props.callback then
				props.callback(self)
			end
			self:stop()
		end
	}

	edge:connect_signal('mouse::enter', function()
		if timer.started then
			timer:again()
		else
			timer:start()
		end
	end)

	edge:connect_signal('mouse::leave', function()
		if timer.started then
			timer:stop()
		end
	end)

	return edge
end

function hotedge.mt.__call(_, ...)
	return hotedge.new(...)
end

return setmetatable(hotedge, hotedge.mt)
--[[
return function(screen)
	screen.edge_bc = wibox {
		screen    = screen,
		visible   = true,
		ontop     = true,
		opacity   = 0.0,
		x         = (screen.geometry.width-screen.dock.width)/2,
		y         = (screen.geometry.height - 3),
		height    = 3,
		width     = screen.dock.width,
		type      = 'utility'
	}

	bc_timer = gtimer {
		timeout   = execute_time,
		call_now  = false,
		autostart = false,
		callback  = function(self)
			awesome.emit_signal('dock::partial_show')
			self:stop()
		end
	}

	screen.edge_bc:connect_signal('mouse::enter', function()
		if bc_timer.started then
			bc_timer:again()
		else
			bc_timer:start()
		end
	end)

	screen.edge_bc:connect_signal('mouse::leave', function()
		if bc_timer.started then
			bc_timer:stop()
		end
	end)

	screen.edge_bt = wibox {
		screen    = screen,
		visible   = true,
		ontop     = true,
		opacity   = 0.0,
		x         = screen.geometry.x,
		y         = screen.geometry.y,
		height    = 3,
		width     = screen.geometry.width,
		type      = 'utility'
	}

	bt_timer = gtimer {
		timeout   = 1.5,
		call_now  = false,
		autostart = false,
		callback  = function(self)
			awesome.emit_signal('topbar::partial_show')
			self:stop()
		end
	}

	screen.edge_bt:connect_signal('mouse::enter', function()
		if bt_timer.started then
			bt_timer:again()
		else
			bt_timer:start()
		end
	end)

	screen.edge_bt:connect_signal('mouse::leave', function()
		if bt_timer.started then
			bt_timer:stop()
		end
	end)
end]]

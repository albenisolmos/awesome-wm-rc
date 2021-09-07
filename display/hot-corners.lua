local wibox     = require('wibox')
local gtimer     = require('gears.timer')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local execute_time = 0.40

return function(screen)
	screen.corner_bc = wibox {
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

	screen.corner_bc:connect_signal('mouse::enter', function()
		if bc_timer.started then
			bc_timer:again()
		else
			bc_timer:start()
		end
	end)

	screen.corner_bc:connect_signal('mouse::leave', function()
		if bc_timer.started then
			bc_timer:stop()
		end
	end)

	screen.corner_bt = wibox {
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

	screen.corner_bt:connect_signal('mouse::enter', function()
		if bt_timer.started then
			bt_timer:again()
		else
			bt_timer:start()
		end
	end)

	screen.corner_bt:connect_signal('mouse::leave', function()
		if bt_timer.started then
			bt_timer:stop()
		end
	end)
end

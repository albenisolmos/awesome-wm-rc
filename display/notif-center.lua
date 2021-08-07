local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local animate   = require 'util.animate'

return function(screen)
	local offscreen, onscreen = screen.geometry.width, screen.geometry.width - dpi(300)

	local notifcenter = wibox {
		type    = 'dnd',
		screen  = screen,
		ontop   = true,
		visible = true,
		width   = dpi(300),
		height  = screen.workarea.height,
		x       = offscreen,
		y       = screen.workarea.y,
		bg      = beautiful.transparent,
		input_passthrough = true
		widget  = {
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(10),
			require 'widget.notif-list',
			require 'widget.grid-widgets'
		}
	}

	awesome.connect_signal('notifcenter::toggle', function()
		if notifcenter.x == offscreen then
			animate.move.x(notifcenter, onscreen)
		else
			animate.move.x(notifcenter, offscreen)
		end
	end)

	awesome.connect_signal('notifcenter::hide', function()
		if notifcenter.x == onscreen then
			animate.move.x(notifcenter, offscreen)
		end
	end)
end

local ascreen   = require('awful.screen')
local gtimer     = require('gears.timer')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local partial_show = false

return function(screen)
	local topbar = wibox({
		screen = screen,
		type = 'dock',
		ontop = false,
		visible = true,
		height = dpi(21),
		width = screen.geometry.width,
		bg = beautiful.transparent,
		widget = {
			layout = wibox.layout.align.horizontal,
			{
				layout = wibox.layout.align.horizontal,
				require 'widget.user',
				require 'widget.workspaces',
				require 'widget.tasklist'(screen)
			},
			nil,
			{
				layout = wibox.layout.fixed.horizontal,
				require 'widget.systray',
				require 'widget.taglist'(screen),
				require 'widget.sound.applet',
				require 'widget.hardware-monitor.applet',
				require 'widget.dollar.applet',
				require 'widget.center.applet',
				require 'widget.clock.applet'
			}
		}
	})
	topbar:struts( { top = topbar.height } )

	function topbar:hide()
		partial_show = false
		topbar:struts( { top = 0 } )
		self.y = -self.height
	end

	local time_to_hide_topbar = gtimer {
		timeout = 1,
		autostart = false,
		single_shot = true,
		callback = function()
			topbar:hide()
		end
	}

	topbar:connect_signal('mouse::enter', function()
		if partial_show then
			time_to_hide_topbar:stop()
		end
	end)

	topbar:connect_signal('mouse::leave', function()
		if partial_show then
			time_to_hide_topbar:start()
		end
	end)

	function topbar:show()
		partial_show = false
		self:struts( { top = topbar.height } )
		self.ontop = false
		self.y = 0
	end

	function topbar:partial_show()
		partial_show = true
		self.ontop = true
		self.y = 0
		time_to_hide_topbar:start()
	end

	local function clients_change_topbar()
		local t = ascreen.focused().selected_tag

		for _, c in pairs(t:clients()) do
			if c.fullscreen and not c.minimized then
				topbar:hide()
				topbar.bg = beautiful.transparent
				return
			elseif c.maximized or (not c.floating and not c.minimized) and c.skip_taskbar then
				topbar.bg = beautiful.titlebar_bg
				topbar:show()
				return
			end
		end

		topbar.bg = beautiful.transparent
		topbar:show()
	end

	awesome.connect_signal('topbar::update', clients_change_topbar)
	client.connect_signal('property::minimized', clients_change_topbar)
	client.connect_signal('property::maximized', clients_change_topbar)
	awesome.connect_signal('topbar::partial_show', function()
		topbar:partial_show()
	end)
	client.connect_signal('property::fullscreen', function(c)
		if c.fullscreen then
			topbar:hide()
		else
			topbar:show()
		end
	end)

	return topbar
end

--[[ Dynamic Color Topbar
Gdk.init({})
local function get_pixels(x, y)
local w = Gdk.get_default_root_window()
local pb = Gdk.pixbuf_get_from_window(w, x, y, 1, 1)
local bytes = pb:get_pixels()
return bytes:gsub('.', function(c)
return ('%02x'):format(c:byte())
end)
end

dynamic_color = gears.gtimer {
timeout = 0.4,
autostart = false,
single_shot = true,
callback = function()
topbar.bg = '#' .. get_pixels(10, 30)
end
}
]]

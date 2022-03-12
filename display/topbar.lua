local ascreen   = require('awful.screen')
local gtimer     = require('gears.timer')
local gshape = require('gears.shape')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local partial_show = false
local height = dpi(21)
local increased_height = height + 20 + dpi(_G.preferences.client_rounded_corners)
local widget = require('widget')

return function(screen)
	local topbar = wibox({
			screen = screen,
			type = 'dock',
			ontop = false,
			visible = true,
			height = height,
			width = screen.geometry.width,
			bg = beautiful.transparent,
			widget = wibox.widget {
				layout = wibox.container.margin,
				id = 'margin',
				{
					layout = wibox.layout.align.horizontal,
					{
						layout = wibox.layout.align.horizontal,
						widget {
							margin= 2,
							padding = 5,
							require 'widget.workspaces'
						}
					},
					require 'widget.tasklist'(screen),
					{
						layout = wibox.layout.fixed.horizontal,
						require 'widget.systray',
						require 'widget.taglist'(screen),
						require 'widget.sound.applet',
						require 'widget.hardware-monitor.applet',
						require 'widget.dollar.applet',
						require 'widget.clock.applet'
					}
				}
			}
		})

	topbar:struts({ top = 0 })
	local margin = topbar.widget:get_children_by_id('margin')[1]

	local function topbar_reset_size()
		--return
		if topbar.height ~= height then
			topbar.height = height
			topbar:struts({ top = height })
			margin.bottom = 0
			topbar.shape = gshape.rectangle
		end
	end

	local function topbar_shape(cr, w, h)
		--local degrees = math.pi / 180.0;
		--cr:arc(w - radius, radius, radius, -90 * degrees, 0 * degrees)
		--cr:arc_negative(w - radius, h - radius , radius, 0 * degrees, -90 * degrees)
		--cr:arc_negative(radius, h - radius, radius, -90 * degrees, 180 * degrees)
		--cr:arc(radius, radius, radius, 180 * degrees, 270 * degrees)
	end

	local function topbar_inc_size()
		--if topbar.height ~= increased_height then
		--	margin.bottom = 35
		--	topbar.height = increased_height
		--	topbar:struts({ top = increased_height - radius - 20 })
		--	topbar.shape = topbar_shape
		--end
	end

	function topbar:hide()
		if _G.is_popup_visible then return end
		partial_show = false
		topbar:struts({ top = 0 })
		self.y = -self.height
	end

	local time_to_hide_topbar = gtimer {
		timeout = 0.7,
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
		self:struts({ top = topbar.height })
		self.ontop = false
		self.y = 0
	end

	function topbar:partial_show()
		partial_show = true
		self.ontop = true
		self.y = 0
		time_to_hide_topbar:start()
	end

	local function change_topbar(c)
		if c.fullscreen and not c.minimized then
			topbar:hide()
			topbar.bg = beautiful.transparent
			topbar_reset_size()
			return true
		elseif c.maximized
			or (not c.floating and not c.minimized)
			and c.skip_taskbar then
			topbar.bg = beautiful.topbar_bg
			topbar:show()
			topbar_inc_size()
			return true
		end
	end

	local function update_topbar()
		local t = ascreen.focused().selected_tag

		for _, c in pairs(t:clients()) do
			if change_topbar(c) then
				return
			else
				topbar_reset_size()
			end
		end

		topbar.bg = beautiful.transparent
		topbar:show()
	end

	awesome.connect_signal('topbar::update', update_topbar)
	client.connect_signal('property::minimized', update_topbar)
	client.connect_signal('property::maximized', update_topbar)
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

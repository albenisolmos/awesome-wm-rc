local wibox = require('wibox')
local spawn = require('awful.spawn')
local gshape = require('gears.shape')
local beautiful = require('beautiful')
local build_applet = require 'widgets.applet'
local clickable = require('widgets.clickable')
local dpi = beautiful.xresources.apply_dpi

local function item(label, on_click)
	return wibox.widget {
		layout = clickable,
		callback = function()
			on_click()
			awesome.emit_signal('popup::hide')
		end,
		bg_normal = beautiful.transparent,
		bg_hover  = beautiful.bg_hover,
		bg_press  = beautiful.bg_press,
		shape     = function(cr, w, h)
			gshape.rounded_rect(cr, w, h, dpi(5))
		end,
		forced_width = dpi(50),
		{
			widget = wibox.container.margin,
			bottom = dpi(4),
			top = dpi(4),
			left = dpi(10),
			right = dpi(10),
			{
				widget = wibox.widget.textbox,
				text = label
			}
		}
	}
end

return build_applet(
	wibox.widget {
		widget = wibox.widget.imagebox,
		image = require('gears.filesystem').get_xdg_config_home() .. 'icon-user.jpg'
	},
	wibox.widget {
			layout = wibox.layout.fixed.vertical,
			forced_width = dpi(250),
			item('Sleep', function()
				--spawn([[dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Suspend" boolean:true]])
				spawn('dm-tool lock')
			end),
			item('Shutdown', function()
				spawn([[dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.PowerOff" boolean:true]])
			end),
			item('Reboot', function()
				spawn([[dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Reboot" boolean:true]])
			end),
			item('', function()end),
			item('', function()end)
	})

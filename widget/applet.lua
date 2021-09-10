local button      = require('awful.button')
local shape      = require('gears.shape')
local wibox      = require('wibox')
local beautiful  = require('beautiful')
local dpi        = beautiful.xresources.apply_dpi
local multispawn = require 'util.multispawn'
local apps      = require 'apps'

return function(widget, popup_widget, on_hold)
	local applet = wibox.widget {
		layout = wibox.container.background,
		bg     = beautiful.transparent,
		shape  = function(cr, w, h) shape.rounded_rect(cr, w, h, 5) end,
		forced_width = dpi(45),
		{
			layout = wibox.container.margin,
			left = dpi(12),
			top = dpi(2),
			bottom = dpi(2),
			widget
		}
	}

	local spawn = multispawn {
		timeout = 3,
		on_click = function()
			if not popup_widget then return end
			if type(popup_widget) == 'function' then
				awesome.emit_signal('popup::hide')
				popup_widget()
			else
				awesome.emit_signal('popup::open', popup_widget)
			end
		end,
		on_hold = function()
			if not on_hold then return end
			if type(popup_widget) == 'function' then
			applet:set_bg(beautiful.transparent)
			awesome.emit_signal('popup::hide')
			on_hold()
		end
	}

	applet.buttons = {
		button({}, 1, function()
			spawn:start()
			applet.bg = beautiful.bg_card
		end,
		function()
			if type(popup_widget) == 'function' then
				applet.bg = beautiful.transparent
			end
			spawn:stop()
		end)
	}

	function applet:set_image(img)
		widget:set_image(img)
	end

	awesome.connect_signal('popup::hide', function()
		if type(popup_widget) ~= 'function' then
			applet:set_bg(beautiful.transparent)
		end
	end)

	awesome.connect_signal('popup::changed', function(widget)
		if popup_widget ~= widget then
			applet:set_bg(beautiful.transparent)
		end
	end)

	return applet
end

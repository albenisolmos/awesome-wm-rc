local button      = require('awful.button')
local shape      = require('gears.shape')
local wibox      = require('wibox')
local beautiful  = require('beautiful')
local gtable = require('gears.table')
local dpi        = beautiful.xresources.apply_dpi
local multispawn = require('utils.multispawn')

return function(widget, popup_widget, on_hold)
	local applet = wibox.widget {
		layout = require('widgets.box'),
		bg     = beautiful.transparent,
        bg_hover = '#ffffff30',
		shape  = function(cr, w, h)
			shape.rounded_rect(cr, w, h, dpi(5))
		end,
		forced_width = dpi(45),
		{
			layout = wibox.container.margin,
			left = dpi(12),
			top = dpi(1),
			bottom = dpi(1),
			{
				widget = widget
			}
		}
	}

	local spawn = multispawn {
		timeout = 3,
		on_click = function()
			if not popup_widget then return end
			if type(popup_widget) == 'function' then
				awesome.emit_signal('popup::hide')
				popup_widget(applet)
			else
				awesome.emit_signal('popup::open', popup_widget)
                applet.bg = '#ffffff40'
			end
		end,
		on_hold = function()
			applet.bg = beautiful.transparent
			awesome.emit_signal('popup::hide')
			if not on_hold then return end
			on_hold(applet)
		end
	}

	applet:buttons(gtable.join(
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
	))

	function applet:set_image(img)
		widget:set_image(img)
	end

	function applet:actions(_popup_widget, _on_hold)
		popup_widget = _popup_widget
		on_hold = _on_hold
	end

	awesome.connect_signal('popup::hide', function()
		if type(popup_widget) ~= 'function' then
			applet.bg = beautiful.transparent
		end
	end)

	awesome.connect_signal('popup::changed', function()
		if popup_widget ~= widget then
			applet.bg = beautiful.transparent
		end
	end)

	return applet
end

local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local current_widget = {}
local content = wibox.layout.fixed.vertical()

return function(screen)
	local popup = wibox {
		screen     = screen,
		type       = 'dock',
		ontop      = true,
		visible    = false,
		y          = screen.geometry.y + 27,
		bg         = beautiful.bg,
		shape      = shape.rounded_rect,
		widget     = {
			layout = wibox.container.margin,
			margins = dpi(10),
			content
		}
	}

	local function dynamic_size()
		popup.width, popup.height = wibox.widget.base.fit_widget(
			content,
			{ dpi = screen.dpi or beautiful.xresources.get_dpi() },
			current_widget,
			280,
			650)
	end

	local function set_position()
		local x = mouse.coords().x
		local position = 0
		local screen_width, screen_x = screen.geometry.width, screen.geometry.x

		if (x + popup.width/2) > screen_width then
			position = screen_width - popup.width - dpi(10)
		elseif (x - popup.width) < screen_x then
			position = screen_x + dpi(10)
		else
			position = x - popup.width / 2
		end

		popup.x = position
	end

	awesome.connect_signal('popup::new_object', function(obj)
		obj:connect_signal('button::release', function()
			awesome.emit_signal('popup::show')
		end)
	end)

	awesome.connect_signal('popup::open', function(widget)
		if current_widget == widget and popup.visible then
			awesome.emit_signal('popup::hide')
			return
		end
		content.children[1] = widget
		current_widget = widget
		dynamic_size()
		set_position()
		awesome.emit_signal('popup::show')
		awesome.emit_signal('popup::changed', current_widget)
	end)

	awesome.connect_signal('popup::change_widget', function(widget)
		if current_widget == widget and popup.visible then
			awesome.emit_signal('popup::hide')
			return
		end
		content.children[1] = widget
		current_widget = widget
		dynamic_size()
	end)

	awesome.connect_signal('popup::show', function()
		if not popup.visible then
			popup.visible = true
			popup.y = screen.geometry.y + 27
			_G.is_popup_visible = true
		end
	end)

	awesome.connect_signal('popup::hide', function()
		if popup.visible then
			popup.y = screen.geometry.y + 21
			popup.visible = false
			_G.is_popup_visible = false
		end
	end)

	popup:connect_signal('property::visible', function()
		awesome.emit_signal('popup::visible', popup.visible)
	end)
end

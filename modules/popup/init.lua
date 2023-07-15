local wibox     = require('wibox')
local gshape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local popup_gap = dpi(5)
local current_widget = {}
local content = wibox.layout.fixed.vertical()

return {on_screen = function(screen)
	local popup = wibox {
		screen     = screen,
		type       = 'dock',
		ontop      = true,
		visible    = false,
		y          = screen.geometry.y + 27,
		bg         = beautiful.wibox_bg,
        border_width = dpi(2),
        border_color = beautiful.border_focus,
		shape      = gshape.rounded_rect,
		widget     = wibox.widget {
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
		local coords = mouse.coords()
		local mouse_x = coords.x
		local mouse_y = coords.y
		local coord_y, coord_x
		local screen_width = screen.geometry.width
		local screen_height = screen.geometry.height
		local screen_x, screen_y = screen.geometry.x, screen.geometry.y
		local workarea_y = screen.workarea.y

		-- For 'y'
		if mouse_y + popup.height >= screen_height then
			coord_y = screen.workarea.height - popup.height - popup_gap
		elseif mouse_y - popup.height <= screen_y then
			coord_y = workarea_y + popup_gap
		end

		-- For 'x'
		if (mouse_x + popup.width/2) > screen_width then
			coord_x = screen_width - popup.width - dpi(10)
		elseif (mouse_x - popup.width) < screen_x then
			coord_x = screen_x + dpi(10)
		else
			coord_x = mouse_x - popup.width / 2
		end

		if popup.y ~= coord_y then
			popup.y = coord_y
		end
		if popup.x ~= coord_x then
			popup.x = coord_x
		end
	end

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
		end
	end)

	awesome.connect_signal('popup::hide', function()
		if popup.visible then
			popup.visible = false
		end
	end)

	popup:connect_signal('property::visible', function()
		awesome.emit_signal('popup::visible', popup.visible)
	end)
end}

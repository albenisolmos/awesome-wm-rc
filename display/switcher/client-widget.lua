local wibox = require('wibox')
local shape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

return function(c)
	if not c then error('No client provided') end

	local client_widget = wibox.widget {
		layout        = wibox.layout.fixed.vertical,
		spacing       = dpi(5),
		forced_height = dpi(120),
		forced_width  = dpi(120),
		client        = c,
		{
			layout        = wibox.container.background,
			bg            = beautiful.transparent,
			shape         = shape.rounded_rect,
			forced_height = dpi(80),
			forced_width  = dpi(80),
			id            = 'bg',
			{
				layout = wibox.container.place,
				{
					widget = wibox.widget.imagebox,
					image = c.icon,
					id = 'img'
				}
			}
		},
		{
			layout = wibox.container.place,
			{
				layout = wibox.container.background,
				fg = beautiful.transparent,
				id = 'fg',
				{
					widget = wibox.widget.textbox,
					text = c.name,
					id = 'text'
				}
			}
		}
	}

	local img = client_widget:get_children_by_id('img')[1]
	local bg = client_widget:get_children_by_id('bg')[1]
	local fg = client_widget:get_children_by_id('fg')[1]
	local text = client_widget:get_children_by_id('text')[1]

	function client_widget:set_focus(focus)
		if focus then
			bg:set_bg(beautiful.bg_chips)
			fg:set_fg(beautiful.fg_soft_focus)
		else
			bg:set_bg(beautiful.transparent)
			fg:set_fg(beautiful.transparent)
		end
	end

	function client_widget:change_client(_c)
		if self.client ~= _c then
			self.client = _c
			text.text = _c.name
			img.image = _c.icon
			self:emit_signal('widget::redraw_needed')
			self:emit_signal('widget::layout_changed')
		end
	end

	return client_widget
end

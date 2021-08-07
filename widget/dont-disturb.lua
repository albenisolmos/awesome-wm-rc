local awful     = require('awful')
local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local widgetDontDisturb = wibox.widget
{
	layout = wibox.container.background,
	bg = beautiful.bg_card,
	shape = shape.rounded_rect,
	forced_width = dpi(300),
	forced_height = dpi(60),
	{
		layout = wibox.container.margin,
		margins = dpi(10),
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(8),
			{
				layout = wibox.container.margin,
				left = dpi(5),
				top = dpi(5),
				bottom = dpi(5),
				{
					layout = wibox.container.background,
					bg     = beautiful.bg_hover,
					shape  = shape.circle,
					forced_height = 25,
					forced_width = 25,
					id     = 'id_bg',
					{
						layout  = wibox.container.margin,
						margins = dpi(5),
						{
							layout = wibox.container.place,
							{
								widget  = wibox.widget.imagebox,
								image   = beautiful.icon_sleep
							}
						}
					}
				}
			},
			{
				widget = wibox.widget.textbox,
				font = beautiful.font_bold,
				text = 'Do Not Disturb',
				forced_width = 150
			}
		}
	}
}

return widgetDontDisturb

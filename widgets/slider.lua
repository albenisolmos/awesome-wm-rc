local wibox               = require('wibox')
local shape               = require('gears.shape')
local beautiful           = require('beautiful')
local spawn               = require('awful.spawn')
local dpi                 = beautiful.xresources.apply_dpi
local clickable           = require('widgets.clickable')

return function( title, icon, icon_soft, slider, spawn_button )
	local slider = wibox.widget
	{
		layout        = wibox.container.background,
		bg            = beautiful.bg_card,
		shape         = shape.rounded_rect,
		forced_height = dpi(70),
		{
			layout  = wibox.container.margin,
			margins = dpi(10),
			{
				layout  = wibox.layout.fixed.vertical,
				spacing = dpi(3),
				{
					widget = wibox.widget.textbox,
					font   = beautiful.font_bold,
					text   = title
				},
				{
					layout        = wibox.layout.fixed.horizontal,
					forced_height = dpi(25),
					spacing       = dpi(5),
					{
						layout = wibox.layout.stack,
						slider,
						{
							layout = wibox.container.margin,
							top    = dpi(5),
							bottom = dpi(5),
							left   = dpi(3),
							{
								widget = wibox.widget.imagebox,
								image = icon,
							}
						}
					},
					{
						layout    = clickable,
						bg        = beautiful.bg_medium,
						bg_normal = beautiful.bg_medium,
						bg_hover  = beautiful.bg_hover,
						bg_press  = beautiful.bg_press,
						callback  = function() spawn(spawn_button) end,
						shape     = shape.circle,
						{
							layout  = wibox.container.margin,
							margins = dpi(2),
							{
								layout = wibox.container.place,
								{
									widget = wibox.widget.imagebox,
									image  = icon_soft,
								}
							}
						}
					}
				}
			}
		}
	}
	return slider
end

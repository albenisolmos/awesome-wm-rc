local wibox = require('wibox')
local shape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local bool = false

widgetModes = wibox.widget
{
	bg = beautiful.bg_card,
	shape = shape.rounded_rect,
	layout = wibox.container.background,
	{
		margins = dpi(5),
		layout = wibox.container.margin,
		{
			layout = wibox.layout.fixed.vertical,
			{
				id = 'button_mode',
				bg = '#00000000',
				layout = wibox.container.background,
				{
					layout = wibox.container.place,
					{
						id = 'icon_mode',
						resize = true,
						forced_height = dpi(25),
						forced_width = dpi(25),
						image = beautiful.icon_desktop,
						widget = wibox.widget.imagebox
					},
				}
			},
			{
				markup = '<span font="Ubuntu Medium 9">Solid\nColors</span>',
				align = 'center',
				widget = wibox.widget.textbox
			}
		}
	}
}

widgetModes:get_children_by_id('button_mode')[1]:connect_signal(
'button::release', function()
	for s in screen do
		if bool == false then
			s.desktop.bg = '#242424D8',
			widgetModes:get_children_by_id('icon_mode')[1]:set_image(beautiful.icon_desktop_active)
			bool = true
		else
			s.desktop.bg = beautiful.transparent,
			widgetModes:get_children_by_id('icon_mode')[1]:set_image(beautiful.icon_desktop)
			bool = false
		end
	end
end)

return widgetModes

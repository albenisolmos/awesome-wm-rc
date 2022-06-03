local spawn = require('awful.spawn')
local shape = require('gears.shape')
local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local widgetScreenshot = wibox.widget
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
				layout = wibox.layout.align.horizontal,
				id = 'button',
				expand = 'none',
				nil,
				{
					id = 'id_icon',
					image = beautiful.icon_desktop,
					forced_height = dpi(25),
					forced_width = dpi(25),
					widget = wibox.widget.imagebox
				},
				nil,
			},
			{
				markup = '<span font="Ubuntu Medium 9">Screenshot</span>',
				align = 'center',
				widget = wibox.widget.textbox
			}
		}
	}
}

widgetScreenshot:get_children_by_id('button')[1]:connect_signal(
'button::press', function()
	widgetScreenshot:get_children_by_id('id_icon')[1]:set_image(beautiful.icon_desktop_active)
end)

widgetScreenshot:get_children_by_id('button')[1]:connect_signal(
'button::release', function()
	for s in screen do
		s.controlCenter.visible = false
	end
	spawn('scrot -s')
	widgetScreenshot:get_children_by_id('id_icon')[1]:set_image(beautiful.icon_desktop)
end)

return widgetScreenshot

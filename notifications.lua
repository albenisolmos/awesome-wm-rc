local awful     = require('awful')
local wibox     = require('wibox')
local shape     = require('gears.shape')
local naughty   = require('naughty')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

naughty.config.defaults.title = 'System Notification'
naughty.config.defaults.border_width = 1
naughty.config.defaults.margin = dpi(10)
naughty.config.defaults.position = 'top_right'
naughty.config.defaults.shape = shape.rounded_rect
naughty.config.defaults.icon_size = dpi(60)
naughty.config.defaults.ontop = true
naughty.config.defaults.timeout = 5

naughty.config.spacing = dpi(10)
naughty.config.padding = dpi(10)

naughty.config.presets.critical.bg = beautiful.notification_critical

naughty.config.icon_dirs = {
	'/usr/share/icons/hicolor/',
	'/usr/share/icons/gnome/',
	'/usr/share/icons/pixmaps/'
}

naughty.config.icon_formats = {
	'png',
	'svg',
	'jpg',
	'gif'
}

naughty.connect_signal('request::display', function(n)
	if n.app_name == '' then
		n.app_name = 'System Notification'
	end
	naughty.layout.box {
		notification = n,
		type = 'notification',
		screen = awful.screen.preferred(),
		shape = beautiful.notification_shape,
		widget_template = {
			layout = wibox.container.margin,
			margins = dpi(10),
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(10),
				{
					layout = wibox.layout.align.vertical,
					spacing = dpi(10),
					{
						layout = wibox.container.background,
						bg = beautiful.transparent,
						fg = beautiful.fg_soft,
						{
							layout = wibox.layout.fixed.horizontal,
							forced_height = dpi(25),
							spacing = dpi(5),
							{
								layout = wibox.container.place,
								{
									widget = wibox.widget.imagebox,
									image = n.app_icon or beautiful.icon_notification_new,
									forced_height = dpi(15),
									forced_width =dpi(15)
								}
							},
							{
								widget = wibox.widget.textbox,
								text = n.app_name:upper(),
								font = beautiful.font_small,
								align = 'left',
								valing = 'center'
							}
						}
					},
					{
						widget = wibox.widget.textbox,
						text = n.title or '',
						font = beautiful.font_bold
					},
					{
						widget = naughty.widget.message,
						align = 'left'
					}
				},
				{
					widget = naughty.widget.icon,
					resize_strategy = 'center'
				}
			}
		}
	}
end)

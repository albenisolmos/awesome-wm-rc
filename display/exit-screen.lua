local shape     = require('gears.shape')
local awful     = require('awful')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local clickable = require 'widget.clickable'

local function add_button(icon, name, action)
	return wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(5),
		{
			widget    = clickable,
			bg        = beautiful.bg_press,
			bg_normal = beautiful.bg_press,
			bg_hover  = beautiful.bg_hover,
			bg_press  = beautiful.bg_press,
			shape     = shape.rounded_rect,
			callback  = function() awful.spawn.with_shell('sleep 0.5 && ' .. action) end,
			forced_height = dpi(100),
			forced_width = dpi(100),
			{
				margins = dpi(10),
				layout = wibox.container.margin,
				{
					widget = wibox.widget.imagebox,
					image = icon,
					resize = true
				}
			}
		},
		{
			widget = wibox.widget.textbox,
			markup = '<span font="SF Pro Display 18">' .. name .. '</span>',
			align = 'center',
			valing = 'center'
		}
	}
end

return function(screen)
	local exitScreen = wibox
	{
		screen  = screen,
		type    = 'normal',
		position= 'center',
		ontop   = true,
		visible = false,
		bg      = beautiful.bg,
		width   = screen.geometry.width,
		height  = screen.geometry.height,
		x       = screen.geometry.x,
		y       = screen.geometry.y,
		widget  = {
			id = 'area_exit_screen',
			layout = wibox.container.place,
			{
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(10),
				{
					layout = wibox.container.place,
					{
						layout = wibox.container.background,
						bg = beautiful.bg_press,
						shape = shape.rounded_bar,
						forced_height = dpi(130),
						forced_width = dpi(130),
						{
							layout = wibox.container.margin,
							margins = dpi(5),
							{
								widget = wibox.widget.imagebox,
								image = beautiful.icon_user,
							}
						}
					}
				},
				{
					widget = wibox.widget.textbox,
					align = 'center',
					id = 'user'
				},
				{
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(10),
					{
						widget = wibox.widget.textbox,
						id = 'message',
						align = 'center',
					},
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(40),
						add_button(beautiful.icon_sleep,   'Sleep',    'dm-tool lock'),
						add_button(beautiful.icon_lock,    'Lock',     'dm-tool switch-to-greeter'),
						add_button(beautiful.icon_shutdown,'Shutdown', 'poweroff'),
						add_button(beautiful.icon_restart, 'Restart',  'reboot')
					}
				}
			}
		}
	}

	awesome.connect_signal('exitscreen::show', function()
		exitScreen.visible = true
	end)

	exitScreen:get_children_by_id('area_exit_screen')[1]:connect_signal(
	'button::release', function(self)
		exitScreen.visible = false
	end)

	awful.spawn.easy_async('bash -c whoami', function(stdout)
		local user = stdout:gsub('^%s*(.-)%s*$', '%1')

		exitScreen:get_children_by_id('user')[1]:set_markup
		('<span font="Ubuntu 20">' .. user .. '</span>')

		exitScreen:get_children_by_id('message')[1]:set_markup
		('<span font="Ubuntu 30">Choose wisely, ' .. user .. ' !</span>')
	end)
end

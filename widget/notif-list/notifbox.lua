local wibox     = require("wibox")
local shape     = require('gears.shape')
local abutton   = require('awful.button')
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi
local apps      = require "apps"

return function(n, parent)
	local stack = wibox.layout.stack()
	
	if #n.message > 24 then
		n.message = n.message:sub(1, 24) .. '...'
	end

	local button_delete = wibox.widget { 
		layout        = wibox.container.background,
		bg            = beautiful.bg_hover,
		shape         = shape.circle,
		forced_height = dpi(20),
		forced_width  = dpi(20),
		visible       = false,
		buttons       = {
			abutton({}, 1, function()
				local index = parent:index(stack)
				parent:remove(index)
			end)
		},
		{
			layout  = wibox.container.margin,
			margins = dpi(4),
			{
				widget = wibox.widget.imagebox,
				image  = beautiful.icon_close
			}
		}
	}

	local notifbox = wibox.widget {
		layout = wibox.container.margin,
		left   = dpi(10),
		top    = dpi(10),
		right  = dpi(10),
		hour   = tonumber(os.date('%I')),
		minute = tonumber(os.date('%M')),
		day    = tonumber(os.date('%j')),
		locale = os.date('%p'),
		{
			layout = wibox.container.background,
			bg     = beautiful.bg,
			border_width = dpi(1),
			border_color = beautiful.bg_hover,
			shape  = shape.rounded_rect,
			{
				layout  = wibox.container.margin,
				margins = dpi(10),
				{
					layout  = wibox.layout.fixed.vertical,
					spacing = dpi(5),
					{
						layout  = wibox.layout.align.horizontal,
						expand  = 'none',
						spacing = dpi(5),
						{
							layout  = wibox.layout.fixed.horizontal,
							spacing = dpi(5),
							{
								widget        = wibox.widget.imagebox,
								image         = n.app_icon,
								forced_height = dpi(15),
								forced_width  = dpi(15)
							},
							{
								layout = wibox.container.background,
								bg     = beautiful.transparent,
								fg     = beautiful.fg_soft,
								{
									widget = wibox.widget.textbox,
									text   = n.app_name:upper(),
									font   = beautiful.font_small,
								}
							},
						},
						nil,
						{
							layout = wibox.container.background,
							bg     = beautiful.transparent,
							fg     = beautiful.fg_soft,
							{
								widget = wibox.widget.textbox,
								text   = 'now',
								font   = beautiful.font_small,
								id     = 'clock'
							}
						}
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						{
							layout = wibox.layout.fixed.vertical,
							{
								widget = wibox.widget.textbox,
								text   = n.title,
								font   = beautiful.font_bold
							},
							{
								widget = wibox.widget.textbox,
								text   = n.message,
								font   = beautiful.font
							}
						},
						nil,
						{
							widget        = wibox.widget.imagebox,
							image         = n.icon,
							forced_height = dpi(40),
							forced_width  = dpi(50)
						}
					}
				}
			}
		}
	}

	notifbox:connect_signal('mouse::enter', function()
		button_delete.visible = true
	end)
	notifbox:connect_signal('mouse::leave', function()
		button_delete.visible = false
	end)

	awesome.connect_signal('notifcenter::toggle', function()
		local current_date   = os.date('%I%M%j')
		local current_hour   = tonumber(current_date:sub(1,2))
		local current_minute = tonumber(current_date:sub(3,4))
		local current_day    = tonumber(current_date:sub(5,7))
		local clock = notifbox:get_children_by_id('clock')[1]
		local day, hour, minute = notifbox.day, notifbox.hour, notifbox.minute

		if current_day ~= day then
			clock:set_text(current_day - day .. ' days ago')
		elseif current_hour == hour and current_minute == minute then
			clock:set_text('now')
			return
		elseif current_hour == hour and current_minute > minute then
			clock:set_text(tostring(current_minute - minute .. 'm ago'))
			return
		else
			clock:set_text(string.format('%d:%d %s', hour, minute, notifbox.locale))
		end
	end)
	stack:add(notifbox)
	stack:add(wibox.container.place(button_delete, 'left', 'top'))

	return stack
end

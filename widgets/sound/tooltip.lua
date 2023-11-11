local wibox = require('wibox')
local gtimer = require('gears.timer')
local shape = require('gears.shape')
local placement = require('awful.placement')
local beautiful = require('beautiful')
local dpi  = beautiful.xresources.apply_dpi

local settings = require('settings')
local calc_volume = require('widgets.sound.utils').calc_volume

local tooltip = {}
local current_volumen = 0

return function(screen, volumen)
	current_volumen = volumen
	local slider = wibox.widget {
		widget = wibox.widget.progressbar,
		value = tonumber(volumen),
		max_value = 100,
		color = beautiful.progressbar_fg,
		height = dpi(5)
	}

	local timer = gtimer {
		call_now = false,
		autostart = false,
		timeout = settings.volume_tooltip_time or 1.2,
		callback = function()
			tooltip.visible = false
		end
	}

	awesome.connect_signal('sound::level', function(value, _, block_indicator)
		local volumen = calc_volume(value, current_volumen)
		current_volumen = volumen

		slider:set_value(volumen)

		if block_indicator then
			return
		end

		tooltip.visible = true
		timer:again()
	end)

	tooltip = wibox {
		screen = screen,
		ontop = true,
		type = 'dock',
		width = dpi(200),
		height = dpi(40),
		visible = false,
		bg = beautiful.wibox_bg,
        border_width = beautiful.border_width,
        border_color = beautiful.border_focus,
		shape = function(cr, w, h)
			shape.rounded_rect(cr, w, h, dpi(settings.client_rounded_corners))
		end,
		widget = wibox.widget {
			layout = wibox.container.margin,
			margins = dpi(10),
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(5),
				{
						widget = wibox.widget.imagebox,
						image = beautiful.icon_sound,
                        valign = true,
				},
				slider
			}
		}
	}

	local place = (placement.centered + placement.top)
    place(tooltip, {margins = dpi(20)})
end

local wibox = require('wibox')
local gtimer = require('gears.timer')
local shape = require('gears.shape')
local placement = require('awful.placement')
local beautiful = require('beautiful')
local dpi  = beautiful.xresources.apply_dpi
local calc_volume = require('widget.sound.utils').calc_volume

local tooltip = {}
local current_volumen = 0

return function(screen, volumen)
	current_volumen = volumen
	local slider = wibox.widget {
		widget = wibox.widget.progressbar,
		value = tonumber(volumen),
		max_value = 100,
		color = beautiful.progressbar_fg,
		ticks = true,
		ticks_gap = dpi(2),
		ticks_size = dpi(5),
		width = dpi(120),
		height = dpi(5)
	}

	local timer = gtimer {
		call_now = false,
		autostart = false,
		timeout = 1,
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
		width = dpi(160),
		height = dpi(160),
		visible = false,
		bg = beautiful.bg,
		shape = function(cr, w, h)
			shape.rounded_rect(cr, w, h, dpi(_G.settings.client_rounded_corners))
		end,
		widget = wibox.widget {
			layout = wibox.container.margin,
			margins = dpi(10),
			{
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(10),
				{
					layout = wibox.container.place,
					halign = true,
					valign = true,
					forced_height = dpi(120),
					{
						widget = wibox.widget.imagebox,
						image = beautiful.icon_sound,
						forced_width = dpi(80),
						forced_height = dpi(80)
					},
				},
				nil,
				slider
			}
		}
	}

	placement.centered(tooltip)
end

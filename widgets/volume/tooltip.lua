local wibox = require('wibox')
local gtimer = require('gears.timer')
local shape = require('gears.shape')
local placement = require('awful.placement')
local beautiful = require('beautiful')
local dpi  = beautiful.xresources.apply_dpi

local settings = require('settings')
local volume = require('utils.volume')

local tooltip = {}

local timer = gtimer {
	call_now = false,
	autostart = false,
	timeout = settings.volume_tooltip_time or 1.5,
	callback = function()
		tooltip.visible = false
	end
}

return {
	init = function(screen, vol)
		local slider = wibox.widget {
		widget = wibox.widget.progressbar,
		value = tonumber(vol),
		max_value = 100,
		height = dpi(5)
	}

	volume.connect_signal('property::value', function(_, vol_)
		slider:set_value(vol_)
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
end,
show = function()
	tooltip.visible = true
	timer:again()
end}

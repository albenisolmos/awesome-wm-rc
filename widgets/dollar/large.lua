local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local spawn     = require('awful.spawn')

local value_dollar = wibox.widget.textbox('Loading')
local last_update = wibox.widget.textbox(' ')

local small = wibox.widget {
	layout = wibox.container.background,
	bg     = '#101010',
	shape  = function(cr, w, h)
		shape.rounded_rect(cr, w, h, dpi(15))
	end,
	forced_height = dpi(170),
	forced_width = dpi(170),
	{
		layout = wibox.container.margin,
		margins = dpi(10),
		{
			layout = wibox.layout.align.vertical,
			wibox.widget.textbox('Parallel Dollar'),
			value_dollar,
			last_update
		}
	}
}

small:connect_signal('mouse::enter', function()
	spawn.easy_async_with_shell(
		'curl https://s3.amazonaws.com/dolartoday/data.json',
		function(stdout)
			value_dollar:set_text(stdout:match('"transferencia": (.-)\n'))
			last_update:set_text(stdout:match('"fecha_corta": (.-)\n')
					:gsub('"(.-)"'))
		end
	)
end)

return small

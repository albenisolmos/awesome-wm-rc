local wibox               = require('wibox')
local shape               = require('gears.shape')
local beautiful           = require('beautiful')
local dpi                 = beautiful.xresources.apply_dpi
local clickable           = require 'widget.clickable'

local function build_meter( name, icon,  name_signal )
	local meter = wibox.widget
	{
		layout        = wibox.layout.fixed.vertical,
		spacing       = dpi(5),
		forced_height = dpi(60),
		{
			widget = wibox.widget.textbox,
			markup = name,
			font   = beautiful.font_bold
		},
		{
			layout        = wibox.layout.fixed.horizontal,
			spacing       = dpi(5),
			forced_height = dpi(20),
			{
				bg        = beautiful.bg_chips,
				bg_normal = beautiful.bg_chips,
				shape     = shape.circle,
				widget    = clickable,
				{
					layout  = wibox.container.margin,
					margins = dpi(4),
					wibox.widget.imagebox(icon)
				}
			},
			{
				layout = wibox.container.margin,
				top = dpi(5),
				bottom = dpi(5),
				{
					widget    = wibox.widget.progressbar,
					max_value = 100,
					value     = 0,
					paddings  = 0,
					id        = 'monitor'
				}
			}
		}
	}

	awesome.connect_signal(name_signal, function(value)
		meter:get_children_by_id('monitor')[1]:set_value(value)
	end)

	return meter
end

return wibox.widget {
	layout        = wibox.layout.fixed.vertical,
	spacing       = dpi(5),
	forced_height = dpi(295),
	{
		widget        = wibox.widget.textbox,
		text          = 'Hardware Monitor',
		font          = beautiful.font_bold,
		forced_height = dpi(20)
	},
	{
		layout = wibox.container.margin,
		bottom = dpi(5),
		{
			widget        = wibox.widget.separator,
			forced_height = dpi(1)
		}
	},
	build_meter('CPU',        beautiful.icon_cpu,        'cpu_usage::update'),
	build_meter('RAM',        beautiful.icon_ram,        'ram_usage::update'),
	build_meter('Hard Drive', beautiful.icon_harddrive,  'harddrive_usage::update' ),
	build_meter('Temperature',beautiful.icon_temperature,'temperature_level::update')
}

local wibox     = require('wibox')
local button   = require('awful.button')
local spawn     = require('awful.spawn')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local gtable = require('gears.table')

local slider = wibox.widget {
	expand = 'none',
	forced_width = dpi(220),
	layout = wibox.layout.align.vertical,
	nil,
	{
		widget              = wibox.widget.slider,
		id                  = 'vol_slider',
		value               = 80,
		maximum             = 100,
		color = beautiful.progressbar_fg
	},
	nil
}

local volume_slider = slider.vol_slider

volume_slider:connect_signal('property::value', function(args)
	awesome.emit_signal('sound::level', args.value .. '%')
	awesome.emit_signal('widget::sound::small', args.value)
end)

volume_slider:buttons(gtable.join(
	button({}, 4, nil, function()
		if volume_slider:get_value() > 100 then
			volume_slider:set_value(100)
			return
		end
		volume_slider:set_value(volume_slider:get_value() + 1)
	end),
	button({}, 5, nil, function()
		if volume_slider:get_value() < 0 then
			volume_slider:set_value(0)
			return
		end
		volume_slider:set_value(volume_slider:get_value() - 1)
	end)
))

local function update_slider()
	spawn.easy_async_with_shell(
		[[bash -c "amixer -D pulse sget Master"]],
		function(stdout)
			local volume = string.match(stdout, '(%d?%d?%d)%%')

			volume_slider:set_value(tonumber(volume))
		end
	)
end

update_slider()
awesome.connect_signal('volume_level::update', update_slider)

return slider

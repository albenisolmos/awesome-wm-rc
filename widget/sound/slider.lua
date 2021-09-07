local wibox     = require('wibox')
local shape     = require('gears.shape')
local abutton   = require('awful.button')
local spawn     = require('awful.spawn')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local apps      = require 'apps'
local containerSlider = require 'widget.slider'

local slider = wibox.widget
{
	nil,
	{
		widget              = wibox.widget.slider,
		id                  = 'vol_slider',
		value               = 80,
		maximum             = 100,
	},
	nil,
	expand = 'none',
	forced_width = dpi(220),
	layout = wibox.layout.align.vertical
}

local volume_slider = slider.vol_slider

volume_slider:connect_signal('property::value', function(value)
	awesome.emit_signal('sound::level', volume_slider:get_value() .. '%')
	awesome.emit_signal('widget::sound::small', volume_slider:get_value())
end)

volume_slider:buttons({
	abutton( {}, 4, nil, function()
		if volume_slider:get_value() > 100 then
			volume_slider:set_value(100)
			return
		end
		volume_slider:set_value(volume_slider:get_value() + 1)
	end),

	abutton( {}, 5, nil, function()
		if volume_slider:get_value() < 0 then
			volume_slider:set_value(0)
			return
		end
		volume_slider:set_value(volume_slider:get_value() - 1)
	end)
})

local update_slider = function()
	spawn.easy_async_with_shell(
	[[bash -c "amixer -D pulse sget Master"]],
	function(stdout)
		local volume = string.match(stdout, '(%d?%d?%d)%%')

		volume_slider:set_value(tonumber(volume))
	end)
end

-- Update on startup
update_slider()
-- The emit will come from the global keybind
awesome.connect_signal('volume_level::update', function()
	update_slider()
end)

return slider

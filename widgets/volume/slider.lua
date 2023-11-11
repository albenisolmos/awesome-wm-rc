local wibox = require('wibox')
local abutton = require('awful.button')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local volume = require('utils.volume')
local log = require('utils.debug').log

local block = false

local widget_slider = wibox.widget {
	expand = 'none',
	forced_width = dpi(220),
	layout = wibox.layout.align.vertical,
	nil,
	{
		id  = 'vol_slider',
		widget  = wibox.widget.slider,
		value = 80,
		maximum  = 100,
		buttons = {
			abutton({}, 4, nil, function(self)
				local vol = self.widget:get_value()
				if vol >= 100 then
					return
				end

				vol = vol + 1
				volume.set(vol)
			end),
			abutton({}, 5, nil, function(self)
				local vol = self.widget:get_value()
				if vol <= 0 then
					return
				end

				vol = vol - 1
				volume.set(vol)
			end)
		}
	},
	nil
}

local slider = widget_slider.vol_slider

volume.get(function(value)
	slider.value = value
end)

volume.connect_signal('property::value', function(_, vol)
	block = true
	slider:set_value(vol)
	block = false
end)

slider:connect_signal('property::value', function(self)
	if block then return end

	block = true
	volume.set(self.value)
	block = false
end)

return widget_slider

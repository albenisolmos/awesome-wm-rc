local wibox = require('wibox')
local button = require('awful.button')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gtable = require('gears.table')
local ucolor = require('utils.color')

local BLOCK = false

local widget_slider = wibox.widget {
	expand = 'none',
	forced_width = dpi(220),
	layout = wibox.layout.align.vertical,
	nil,
	{
		widget              = wibox.widget.slider,
		id                  = 'vol_slider',
		value               = 80,
		maximum             = 100,
		color = '#228ae7'
	},
	nil
}

local slider = widget_slider.vol_slider

local function set_value(value)
	BLOCK = true
	slider:set_value(value)
	BLOCK = false
end

awesome.connect_signal('sound::level', function(value, self, block)
	if self == widget_slider then
		return
	end

	local from, to = string.find(value, '%d+')
	local volumen = tonumber(string.sub(value, from, to))
	local action = value:sub(1,1)

	if action == '-' then
		volumen = slider.value - volumen
	elseif action == '+' then
		volumen = slider.value + volumen
	end

	set_value(volumen)
end)

slider:connect_signal('property::value', function(self)
	if BLOCK then return end
	awesome.emit_signal('sound::level', self.value..'%', 
		slider, true)
end)

slider:buttons(gtable.join(
	button({}, 1, nil, function()
		awesome.emit_signal('sound::level',
			slider:get_value()..'%', true)
	end),
	button({}, 4, nil, function()
		local volumen = slider:get_value()
		if volumen >= 100 then
			return
		end

		volumen = volumen + 1

		slider:set_value(volumen)
	end),
	button({}, 5, nil, function()
		local volumen = slider:get_value()
		if volumen <= 0 then
			return
		end
		volumen = volumen - 1

		slider:set_value(volumen)
	end)
))

return widget_slider

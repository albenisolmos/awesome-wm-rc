local base      = require('wibox.widget.base')
local gtable    = require('gears.table')
local gcolor    = require('gears.color')
local surface   = require('gears.surface')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local naughty   = require('naughty')
local dpi       = beautiful.xresources.apply_dpi

local switch = { mt = {} }

local properties = {
	-- Handle
	'handle_color',        'handle_active_color',
	'handle_width',        'handle_height',
	'handle_border_width', 'handle_border_color',
	'handle_margins',      'handle_shape',      

	-- Bar
	'bar_color',        'bar_active_color',
	'bar_height',       'bar_width',
	'bar_border_width', 'bar_border_color',
	'bar_shape',

	state = false
}

-- Create the accessors
for prop in pairs(properties) do
	switch["set_"..prop] = function(self, value)
		local changed = self._private[prop] ~= value
		self._private[prop] = value

		if changed then
			self:emit_signal("property::"..prop, value)
			self:emit_signal("widget::redraw_needed")
		end
	end

	switch["get_"..prop] = function(self)
		-- Ignoring the false's is on purpose
		return self._private[prop] == nil
		and properties[prop]
		or self._private[prop]
	end
end

function switch:set_state_weak(state)
	local changed = self._private.state ~= state
	self._private.state = state

	if changed then
		self:emit_signal('property::state', state)
		self:emit_signal('widget::redraw_needed')
	end
end

function switch:set_state(state)
	local changed = self._private.state ~= state
	self._private.state = state

	awesome.emit_signal('notif::new', type(self._private.callback_active))
	if changed then
		self:emit_signal('property::state', state)
		self:emit_signal('widget::redraw_needed')
	elseif state and self._private.callback_active then
		awesome.emit_signal('notif::new', 'callback_active')
		self._private.callback_active()
	elseif not state and self._private.callback_disable then
		awesome.emit_signal('notif::new', 'callback_disable')
		self._private.callback_disable()
	end
end

function switch:draw(_, cr, width, height)
	local bar_color = self._private.bar_color
	or beautiful.switch_bar_color
	or "#228AE7"

	local bar_color_active = self._private.bar_color_active
	or beautiful.switch_bar_color_active
	or '#999999'

	local bar_width = self._private.bar_width
	or beautiful.switch_bar_width
	or dpi(35)

	local bar_height = self._private.bar_height
	or beautiful.switch_bar_height
	or dpi(20)

	local bar_shape = self._private.bar_shape
	or beautiful.switch_bar_shape
	or shape.rounded_bar

	local bar_border_width = self._private.bar_border_width
	or beautiful.switch_Bar_border_width
	or 2

	local handle_color = self._private.handle_color
	or beautiful.switch_handle_color
	or "#FFFFFF"

	local handle_width = self._private.handle_width
	or beautiful.switch_handle_width
	or dpi(15)

	local handle_height = self._private.handle_height
	or beautiful.switch_handle_height
	or dpi(15)

	local handle_shape = self._private.handle_shape
	or beautiful.switch_handle_shape
	or shape.circle

	local handle_border_width = self._private.handle_border_width
	or beautiful.switch_handle_border_width
	or 2

	local x_offset, y_offset = (width/2) - (bar_width/2), (height/2) - (bar_height/2)
	if self._private.align then
		if self._private.align == 'left' then
			x_offset = 0
		elseif self._private.align == 'right' then
			x_offset = width - bar_width
		end
	end

	-- Draw bar
	if self._private.state then
		cr:set_source(gcolor(bar_color_active))
	else
		cr:set_source(gcolor(bar_color))
	end
	cr:translate(x_offset, y_offset)
	bar_shape(cr, bar_width, bar_height)

	-- Draw the bar border
	if bar_border_width == 0 then
		cr:fill()
	else
		cr:fill_preserve()
		local bar_border_color = self._private.bar_border_color
		or beautiful.switch_bar_border_color
		or '#607F9E'

		cr:set_line_width(bar_border_width)

		if bar_border_color then
			cr:save()
			cr:set_source(gcolor(bar_border_color))
			cr:stroke()
			cr:restore()
		else
			cr:stroke()
		end
	end

	-- Draw the handle
	cr:translate(-x_offset, -y_offset)
	cr:set_source(gcolor(handle_color))

	if self._private.state then
		cr:translate(x_offset + bar_height, y_offset + (bar_height/2 - handle_height/2))
	else
		cr:translate(x_offset, y_offset + (bar_height/2 - handle_height/2))
	end

	handle_shape(cr, handle_width, handle_height)

	if handle_border_width == 0 then
		cr:fill()
	else
		cr:fill_preserve()
		-- Draw the handle border
		local handle_border_color = self._private.handle_border_color or '#000000'

		if handle_border_color then
			cr:set_source(gcolor(handle_border_color))
		end

		cr:set_line_width(handle_border_width)
		cr:stroke()
	end
end

function switch:fit(_, width, height)
	return width, height
end

local function new(args)
	local ret = base.make_widget(nil, nil, {
		enabled_properties = true
	})

	gtable.crush(ret._private, args or {} )
	gtable.crush(ret, switch, true)

	ret:connect_signal('button::release', function(_,_,_, button_id)
		if button_id == 1 then
			if ret:get_state() then
				ret:set_state(false)
			else
				ret:set_state(true)
			end
		end
	end)

	return ret
end

function switch.mt:__call(_, ...)
	return new(...)
end

return setmetatable(switch, switch.mt)

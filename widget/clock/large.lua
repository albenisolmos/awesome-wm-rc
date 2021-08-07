local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local todo      = require 'widget.todo'

local styles = {}

local function rounded_shape(size, partial)
	if partial then
		return function(cr, width, height)
			shape.partially_rounded_rect
			(cr, width, height, false, true, false, true, 5)
		end
	else
		return function(cr, width, height)
			shape.rounded_rect(cr, width, height, size)
		end
	end
end

styles.month   = {
	bg_color     = '00000000',
	border_width = 0,
}

styles.focus   = {
	fg_color = '#d8d8d8',
	bg_color = beautiful.bg_hi,
	markup   = function(t) return '<b>' .. t .. '</b>' end,
	shape    = rounded_shape(5)
}

styles.header  = {
	fg_color = '#d8d8d8',
	bg_color = '#00000000',
	markup   = function(t)
		return '<span font="Ubuntu 15">' .. t .. '</span>'
	end,
}

styles.weekday = {
	fg_color = '#d8d8d8',
	bg_color = '#00000000',
	markup   = function(t)
		return '<span font="Ubuntu 12">' .. t .. '</span>'
	end,
	shape    = rounded_shape(5)
}

local function decorate_cell(widget, flag, date)
	if flag=='monthheader' and not styles.monthheader then
		flag = 'header'
	end

	local props = styles[flag] or {}

	if props.markup and widget.get_text and widget.set_markup then
		widget:set_markup(props.markup(widget:get_text()))
	end

	-- Change bg color for weekends
	local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
	local weekday = tonumber(os.date('%w', os.time(d)))
	local default_bg = '00000000'

	local ret = wibox.widget {
		{
			widget,
			margins = (props.padding or 0) + (props.border_width or 0),
			widget  = wibox.container.margin
		},
		shape              = props.shape,
		shape_border_color = props.border_color or '#b9214f',
		shape_border_width = props.border_width or 0,
		fg                 = props.fg_color or '#999999',
		bg                 = props.bg_color or default_bg,
		widget             = wibox.container.background
	}
	return ret
end

return wibox.widget {
	layout = wibox.layout.fixed.vertical,
	forced_width = dpi(300),
	{
		date     = os.date('*t'),
		font     = 'Ubuntu 12',
		fn_embed = decorate_cell,
		widget   = wibox.widget.calendar.month
	},
	todo
}

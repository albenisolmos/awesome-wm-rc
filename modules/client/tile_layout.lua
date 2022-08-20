local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local M = {}

local function value_from_percentage(percentage, total)
	return math.floor((percentage*total)/100)
end

local function calc_point_xy(widget, tlayout)
	return function(_, args)
		local geo = args.parent

		widget.forced_width = value_from_percentage(tlayout[2], geo.width)
		widget.forced_height = value_from_percentage(tlayout[4], geo.height)

		local t = {
			x = value_from_percentage(tlayout[1], geo.width),
			y = value_from_percentage(tlayout[3], geo.height)
		}

		return t
	end
end

-- Return a widget that reprecent a tile layout (tlayout)
local function tiled_widget_new()
	return wibox.widget {
		layout = wibox.container.background,
		bg = '#228ae7',
		border_color = beautiful.bg_hover,
		{
			widget = wibox.widget.textbox,
			text = 'loco'
		}
	}
end

function M.tile_layout_widget(tlayouts)
	local container = wibox.layout.manual()
	local bg = wibox.container.background()
	bg.bg = '#909090'
	local widget, point

	container.forced_height = dpi(70)
	container.forced_width = dpi(110)
	container:emit_signal('widget::redraw_needed')
	container:emit_signal('widget::layout_changed')
	for n, tlayout in pairs(tlayouts) do
		widget = tiled_widget_new()
		point = calc_point_xy(widget, tlayout)
		container:add_at(widget, point)
	end

	bg.widget=container
	return bg
end

function M.tile_layouts_widget(arr_tlayouts)
	local box = wibox.layout.grid.vertical()
	box.homogeneous = false 
	box.expand = false

	for _, tlayouts in pairs(arr_tlayouts) do
		box:add(M.tile_layout_widget(tlayouts))
	end

	return box
end

return M

local flowbox = {mt = {}}
local gtable = require('gears.table')
local base = require('wibox.widget').base
local inspect = require('utils.inspect')

function flowbox:fit(_, width, height)
    local widgets_nr = #self._private.widgets

    if widgets_nr == 0 then
        return 0, 0
    end

	return width, height
end

function flowbox:layout(context, width, height)
	local result = {}
	local spacing = self._private.spacing or 0
	local max_num_col = self._private.max_num_col or nil
	local y, x = 0, 0
	local num_col = 1
	local h, w

	for _, widget in pairs(self._private.widgets) do
		h, w = height - y, width - x
        w, h = base.fit_widget(self, context, widget, w, h)

		table.insert(result, base.place_widget_at(widget, x+spacing, y, w, h))

		x = w + x + spacing

		if (max_num_col and num_col == max_num_col) or -- if excees max num col
			x + w >= width -- if excees avaliable width
			then
			y = h + y + spacing
			x = 0
			num_col = 0
		end
		num_col = num_col + 1
	end

	return result
end

function flowbox:set_max_num_col(val)
	if val ~= nil then
		self._private.max_num_col = val
        self:emit_signal("widget::layout_changed")
        self:emit_signal("property::max_widget_size", val)
    end
end

local function new(...)
    local ret = require('wibox.layout').fixed.horizontal(...)
    gtable.crush(ret, flowbox, true)
    return ret
end

function flowbox.mt:__call(...)
    return new(...)
end

--@DOC_fixed_COMMON@

return setmetatable(flowbox, flowbox.mt)

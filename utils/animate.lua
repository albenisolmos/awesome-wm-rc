local base = require('wibox.widget.base')
local lgi = require('lgi')

local animate = {
	move = {},
	resize = {},
	widget = {}
}

function animate.widget.scale(widget, scale)
	local space_avaliable
	local ret = base.make_widget()

	local subtract_percent = function(value, percent)
		return math.floor((1-percent/100) * value)
	end

	function ret:fit(_, width, height)
		space_avaliable = math.min(width, height)
		return space_avaliable, space_avaliable
	end

	function ret:layout(_, width, height)
		local scale_percent = subtract_percent(space_avaliable, scale)
		local y = (height / 2) - (scale_percent / 2)
		local x = (width / 2) - (scale_percent / 2)
		return { base.place_widget_at(
		widget,
		x, y,
		scale_percent, scale_percent)}
	end

	function ret:scale(new_scale)
		while scale ~= new_scale do
			if scale > new_scale then
				scale = scale - 1
				ret:emit_signal('widget::layout_changed')
			else
				scale = scale + 1
				ret:emit_signal('widget::layout_changed')
			end
		end
	end

	return ret
end

function animate.move.x(obj, x)
	obj.x = x
	return
	--[[
	if obj.x > x then
		for i=0, x do
			if obj.x == x then return end
			obj.x = obj.x - 1
			obj:emit_signal('property::x')
		end
	elseif obj.x < x then
		for i=0, x do
			if obj.x == x then return end
			obj.x = obj.x + 1
			obj:emit_signal('property::x')
		end
	end
	]]
end

function animate.move.y(obj, y)
	obj.y = y
	return
	--[[
	if obj.y > y then
		for i=0, y do
			if obj.y == y then return end
			obj.y = obj.y - 1
		end
	elseif obj.y < y then
		for i=0, y do
			if obj.y == y then return end
			obj.y = obj.y + 1
		end
	end
	]]
end

function animate.resize.width(obj, width)
	if obj.width > width then
		for i=0, width do
			if obj.width == width then return end
			obj.width = obj.width - 1
		end
	elseif obj.width < width then
		for i=0, width do
			if obj.width == width then return end
			obj.width = obj.width + 1
		end
	end
end

function animate.resize.height(obj, height)
	if obj.height > height then
		for i=0, height do
			if obj.height == height then return end
			obj.height = obj.height - 1
			obj:draw()
		end
	elseif obj.height < height then
		for i=0, height do
			if obj.height == height then return end
			obj.height = obj.height + 1
			obj:draw()
		end
	end
end


return animate

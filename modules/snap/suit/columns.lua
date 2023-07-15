local M = {}
local SNAPS = {}

-- TODO: invert this function span-percentage to percentage-snap
local function calc_span(percentage, total, default_value)
	if percentage == 1 then
		return default_value or 0
	else
		return math.floor(total/percentage)
	end
end

local function set_geometry(obj, geo)
	if type(obj['geometry']) == 'function' then
		obj:geometry(geo)
	else
		obj.x = geo.x
		obj.y = geo.y
		obj.width = geo.width
		obj.height = geo.height
	end
end

M.num_indicators = 2


local function on_geometry(context, num_snapped_objs)
	return {
		y = context.y,
		x = num_snapped_objs == 1 and 0 or (context.width / num_snapped_objs),
		height = context.height,
		width = context.width / (num_snapped_objs == 1 and 2 or num_snapped_objs)
	}

end

function M.add(obj, context, snap_parent, callback, data)
	assert(obj and context)

	if not snap_parent then
		obj.snap_parent = obj
		snap_parent = obj
		SNAPS[obj] = {obj}
	end

	local num_snapped_objs = #SNAPS[snap_parent]

	local geo = {
		y = context.y,
		x = num_snapped_objs == 1 and 0 or (context.width / num_snapped_objs),
		height = context.height,
		width = context.width / (num_snapped_objs == 1 and 2 or num_snapped_objs)
	}

	table.insert(SNAPS[snap_parent], obj)

	if callback then
		callback(obj, geo, data)
	else
		set_geometry(obj, geo)
	end
end

function M.show()
end

return M

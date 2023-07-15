local gtable = require('gears.table')
local M = {
	snaps = {},
	on_request_geometry = nil,
	max_num_snap = 1
}

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

function M:new(max_num_snap, on_request_geometry)
	assert(max_num_snap)
	assert(on_request_geometry)

	local obj = {}
    gtable.crush(obj, M, true)
	obj.on_request_geometry = on_request_geometry
	obj.max_num_snap = max_num_snap
	return obj
end

function M:add(obj, context, snap_parent, callback, data)
	assert(obj)
	assert(context)

	if not snap_parent then
		obj.snap_parent = obj
		snap_parent = obj
		self.snaps[obj] = {obj}
	end

	local num_snapped_objs = #self.snaps[snap_parent]
	local geo = self.on_request_geometry(context, num_snapped_objs)

	table.insert(self.snaps[snap_parent], obj)

	if callback then
		callback(obj, geo, data)
	else
		set_geometry(obj, geo)
	end
end

return setmetatable(M, { __call = function(_, ...)
	return M:new(...)
end})

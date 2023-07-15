local M = {}

local function scale_value(value1, value2, value_context)
	return value1 * value2 / value_context
end

-- NOTE: I think this looks strange and I dont know how works with scale_geometry() because a wrote a long time ago
local function invert_key(key)
	if key == 'y' then return 'height'
	elseif key == 'x' then return 'width'
	else return key end
end

function M.scale_geometry(geo, context_minor, context_major)
	local gap = 2
	local new_geo = {height = 0, width = 0, x = 0, y = 0}
	local inverted_key

	for key in pairs(new_geo) do
		inverted_key = invert_key(key)
		new_geo[key] = scale_value(geo[key], context_minor[inverted_key], context_major[inverted_key])
	end

	-- Gaps
	new_geo.x = new_geo.x + gap
	new_geo.y = new_geo.y + gap
	new_geo.height = new_geo.height - gap * 2
	new_geo.width = new_geo.width - gap * 2

	return new_geo
end

function M.set_geometry(cli, geo)
	cli.x = geo.x
	cli.y = geo.y
	cli.width = geo.width
	cli.height = geo.height
end

return M

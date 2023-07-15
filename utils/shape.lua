local gshape = require('gears.shape')
local M = {}

function M.build(shape)
	local type_value = type(shape)
	if type_value == 'number' then
		return function(cr, w, h)
			gshape.rounded_rect(cr, w, h, shape)
		end
	elseif type_value == 'function' then
		return shape
	end
end

return M

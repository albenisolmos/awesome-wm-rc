local snapper = require('modules.snap.snapper')

local M = snapper(2, function(context, num_snapped_objs)
	return {
		y = num_snapped_objs == 1 and 0 or (context.height / num_snapped_objs),
		x = context.x,
		width = context.width,
		height = context.height / (num_snapped_objs == 1 and 2 or num_snapped_objs)
	}
end)

return M

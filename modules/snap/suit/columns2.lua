local snapper = require('modules.snap.snapper')
local M = snapper(2, function(context, num_snapped_objs)
	return {
		y = context.y,
		x = num_snapped_objs == 1 and 0 or (context.width / num_snapped_objs),
		height = context.height,
		width = context.width / (num_snapped_objs == 1 and 2 or num_snapped_objs)
	}
end)

return M

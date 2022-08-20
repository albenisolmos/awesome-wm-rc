local key = require('awful.key')
local gtable = require('gears.table')
local modkey = SETTINGS.modkey

return function()
	return gtable.join(
		key({ modkey }, 'z', function()
			awesome.emit_signal('tile_layout_indicator::show')
		end, { description = 'Show tile layout menu', group = 'Client'}),
		key({ modkey }, 'x', function()
			awesome.emit_signal('tile_layout_indicator::hide')
		end, { description = 'Hide tile layout menu', group = 'Client'})
	)
end

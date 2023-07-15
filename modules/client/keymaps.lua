local key = require('awful.key')
local gtable = require('gears.table')
local modkey = SETTINGS.modkey

return function()
	return gtable.join(
		key({ modkey }, 'z', function()
			awesome.emit_signal('popup_tile_layouts::toggle')
		end, { description = 'Show tile layout menu', group = 'Client'}),
		key({ modkey }, 'Escape', function()
			awesome.emit_signal('popup_tile_layouts::hide')
		end, { description = 'Hide tile layout menu', group = 'Client'})
	)
end

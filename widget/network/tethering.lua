local network = require 'widget.network'
local beautiful = require('beautiful')

local tethering = network(beautiful.icon_tethering, 'Tethering')

tethering:actions {
	on_click = function() return end,
	on_hold = function() return end
}

return tethering

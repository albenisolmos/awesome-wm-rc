local beautiful = require('beautiful')
local network   = require 'widget.network'

local bluetooth = network(beautiful.icon_bluetooth, 'Bluetooth')
--[[bluetooth:actions {
	on_click = function() end,
	on_hold  = function() end
}
]]
return bluetooth

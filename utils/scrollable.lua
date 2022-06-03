local button     = require('awful.button')
local gtable    = require('gears.table')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

return function(widget)
	local scroll = wibox.layout.manual()
	scroll:add(widget)

	scroll:buttons(gtable.join(
	awful.button({}, 4, function() end),
	awful.button({}, 5, function() end)
	))
end

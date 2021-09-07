local awful     = require('awful')
local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local grid = wibox.widget {
	layout = wibox.layout.grid,
	expand = false,
	orientation = 'horizontal',
	spacing       = dpi(10),
	min_cols_size = dpi(145),
	min_rows_size = dpi(150),
}

grid:add(require 'widget.dollar.small')
grid:add(require 'widget.dollar.small')

return grid

local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

return function(screen)
	local modal = wibox {
		screen  = screen,
		type    = 'utility',
		bg      = '#00000099',
		ontop   = false,
		visible = false,
		height = 1,
		width = 1,
		input_passthrough = true
	}

	awesome.connect_signal('modal::show', function(c)
		modal.x = c.transient_for.x
		modal.y = c.transient_for.y
		modal.height = c.transient_for.height
		modal.width = c.transient_for.width
		modal.visible = true
		c.transient_for:lower()
		c:raise()
	end)

	awesome.connect_signal('modal::hide', function()
		modal.visible = false
	end)

	return modal
end

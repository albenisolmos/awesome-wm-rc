local titlebar = require('awful.titlebar')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi

return function(gestures_buttons, c)
	local buttons = wibox.layout.fixed.horizontal()

	if c.type == 'dialog' then
		buttons:add(titlebar.widget.closebutton(c))
	else
		buttons:add(titlebar.widget.minimizebutton(c))
		buttons:add(titlebar.widget.maximizedbutton(c))
		buttons:add(titlebar.widget.closebutton(c))
	end

	return wibox.widget {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.container.margin,
			left   = dpi(10),
			right  = dpi(10),
			top    = dpi(10),
			bottom = dpi(10),
			titlebar.widget.iconwidget(c)
		},
		{
			widget = titlebar.widget.titlewidget(c),
			align = 'left',
			font = 'Ubuntu 10.3',
			buttons = gestures_buttons 
		},
		buttons
	}
end

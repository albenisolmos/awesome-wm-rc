local awful   = require('awful')
local animate = require 'util.animate'
local wibox   = require("wibox")
local shape   = require('gears.shape')

local tooltip = awful.tooltip {
	delay_show = 1,
	align = 'top',
	mode = 'outside',
	preferred_alignments = 'middle',
	shape = shape.rounded_rect
}

return function(icon, app, name)
	local img = wibox.widget.imagebox(icon, true)
	local item = animate.widget.scale(img, 20)
	item.name = name or nil

	item:buttons({awful.button({ }, 1, function()
		awful.spawn.raise_or_spawn(app)
	end)})

	item:connect_signal('button::press', function()
		item:scale(15)
	end)

	item:connect_signal('button::release', function()
		item:scale(20)
	end)

	item:connect_signal('mouse::enter', function()
		tooltip:set_text(app)
		item:scale(0)
	end)

	item:connect_signal('mouse::leave', function()
		item:scale(20)
	end)

	tooltip:add_to_object(item)

	return wibox.widget {
		layout = wibox.layout.fixed.vertical,
		item,
	}
end

local wibox     = require('wibox')
local shape     = require('gears.shape')
local naughty   = require('naughty')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local notifbox  = require 'widget.notif-list.notifbox'
local animate   = require 'util.animate'
local notiflist = wibox.layout.fixed.vertical()

local b_delete_all = wibox.widget {
	layout  = wibox.container.margin,
	margins = 0,
	id      = 'margin',
	{
		layout = wibox.container.background,
		bg     = beautiful.bg,
		shape  = shape.circle,
		{
			layout  = wibox.container.margin,
			margins = dpi(8),
			{
				layout = wibox.container.place,
				{
					layout        = wibox.widget.imagebox,
					image         = beautiful.icon_close,
					forced_height = dpi(20),
					forced_width  = dpi(20),
				}
			}
		}
	}
}

b_delete_all:connect_signal('button::release', function()
	notiflist:reset()
end)

b_delete_all:connect_signal('button::press', function(self)
	local margin = 3
	while margin ~= 5 do
		margin = margin + 1
		self:set_margins(margin)
	end
end)

b_delete_all:connect_signal('mouse::enter', function(self)
	local margin = 0
	while margin ~= 3 do
		margin = margin + 1
		self:set_margins(margin)
	end
end)

b_delete_all:connect_signal('mouse::leave', function(self)
	local margin = 3
	while margin ~= 0 do
		margin = margin - 1
		self:set_margins(margin)
	end
end)

naughty.connect_signal('request::display', function(n)
	if n.app_name == '' then
		n.app_name = 'System Notification'
	end

	notiflist:insert(1, notifbox({
		app_icon = n.app_icon or beautiful.icon_notification_new,
		app_name = n.app_name,
		title    = n.title,
		message  = n.message,
		icon     = n.icon
	}, notiflist))
end)

return wibox.widget {
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(5),
	notiflist,
	{
		layout = wibox.container.place,
		b_delete_all
	}
}

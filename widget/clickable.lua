local base      = require('wibox.widget.base')
local gtable    = require('gears.table')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local clickable = { mt = {} }

local function new(args)
	local bg = wibox.container.background()
	bg:set_bg(bg.bg_normal)

	bg:connect_signal('mouse::enter', function(self)
		self:set_bg(bg.bg_hover or beautiful.clickable_hover)
		--if bg.on_enter then bg.on_enter() end
	end)
	bg:connect_signal('mouse::leave', function(self)
		self:set_bg(bg.bg_normal or beautiful.clickable_normal)
		--if bg.on_leave then bg.on_leave() end
	end)
	bg:connect_signal('button::press', function(self)
		self:set_bg(bg.bg_press or beautiful.clickable_press)
		--if bg.on_press then bg.on_press() end
	end)
	bg:connect_signal('button::release', function(self)
		self:set_bg(bg.bg_normal or beautiful.clickable_normal)
		--if bg.on_release then bg.on_release() end
	end)
	bg:connect_signal('button::release', function(_,_,_, button_id)
		if button_id ~= 1 or not bg.callback then return end
		bg.callback()
	end)

	return bg
end

function clickable.mt:__call(_, ...)
	return new(...)
end

return setmetatable(clickable, clickable.mt)

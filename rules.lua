local atitlebar = require('awful.titlebar')
local ascreen = require('awful.screen')
local aclient = require('awful.client')
local amouse = require('awful.mouse')
local placement = require('awful.placement')
local abutton = require('awful.button')
local shape = require('gears.shape')
local gtable = require('gears.table')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local rules = require('awful.rules')

local clientbuttons = gtable.join(
	abutton({ }, 1, function(c)
		client.focus = c
		c:raise()
		awesome.emit_signal('menu::hide')
		awesome.emit_signal('popup::hide')
	end),
	abutton({'Mod4'}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		amouse.client.move(c)
	end),
	abutton({'Mod4'}, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		amouse.client.resize(c)
	end)
)

rules.rules = {
	 {
		id = 'global',
		rule = { },
		properties = {
			focus = aclient.focus.filter,
			raise = true,
			screen = ascreen.preferred,
			placement = placement.no_overlap + placement.no_offscreen,
			size_hints_honor  = false,
			buttons = clientbuttons,
			keys = require('keymaps-client')
		},
		callback = function(c)
			if c.requests_no_titlebar then
				atitlebar.hide(c)
			end
			c.shape = function(cr, w, h)
				shape.rounded_rect(cr, w, h,
				dpi(SETTINGS.client_rounded_corners))
			end
		end
	},
	{
		rule_any = { type = { 'normal', 'dialog', 'splash'} },
		properties = { titlebars_enabled = true },
		callback = function(c)
			placement.centered(c, {honor_padding = true,
				honor_workarea = true})
		end
	},
	--[[{
		rule_any = {
			type = { 'normal', 'dialog', 'splash', 'dock', 'menu'}
		},
		callback =  function(c)
		end
	},]]
	{
		id = 'floating',
		rule_any = {
			instance = { 'DTA', 'copyq' },
			name     = { 'Event Tester' },
			role     = { 'AlarmWindow', 'ConfigManager', 'pop-up'}
		},
		properties = { floating = true }
	},
	{ -- Fix requests_no_titlebar and add border
		rule_any = { class = { "Firefox", "Xfce4-terminal", "St"} },
		callback = function(c)
			atitlebar.hide(c)
		end
	},
	{
		rule_any = { class = {'Xfce4-terminal', "St"} },
		properties = {
			border_width = SETTINGS.client_border_width or dpi(1),
			border_color = beautiful.border_normal
		}
	}
}

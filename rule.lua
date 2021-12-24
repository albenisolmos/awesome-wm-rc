local awful = require('awful')
local shape = require('gears.shape')
local gtable = require('gears.table')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local rules = require('awful.rules')

local clientbuttons = gtable.join(
	awful.button({ }, 1, function(c)
		client.focus = c
		c:raise()
		awesome.emit_signal('menu::hide')
		awesome.emit_signal('popup::hide')
	end),
	awful.button({'Mod4'}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.move(c)
	end),
	awful.button({'Mod4'}, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.resize(c)
	end)
)

client.connect_signal('request::unmanage', function(c)
	if c.modal or c.transient_for then
		awesome.emit_signal('modal::hide')
	end
end)

client.connect_signal('property::modal', function(c)
	if c.modal then
		awesome.emit_signal('modal::show', c)
	else
		awesome.emit_signal('modal::hide')
	end
end)

rules.rules = {
	 {
		id = 'global',
		rule = { },
		properties = {
			focus        = awful.client.focus.filter,
			raise        = true,
			screen       = awful.screen.preferred,
			placement    = awful.placement.no_overlap+awful.placement.no_offscreen,
			size_hints_honor  = false,
			buttons = clientbuttons,
			keys = require('client-keys')
		},
		callback = function(c)
			c.border_width = 0
			if c.requests_no_titlebar then
				awful.titlebar.hide(c)
			end
		end
	},
	 {
		rule_any = { type = { 'normal', 'dialog'} },
		properties = { titlebars_enabled = true },
		callback = function(c)
			awful.placement.centered(c, {honor_padding = true, honor_workarea=true})
			c.border_width = beautiful.border_width
			c.border_color = beautiful.border_normal
		end
	},
	{
		rule_any = { type = { 'normal', 'dialog', 'splash', 'dock'} },
		callback = function(c)
			c.shape = function(cr, w, h)
				shape.rounded_rect(cr, w, h, dpi(8))
			end
		end
	},
	{
		id = 'floating',
		rule_any = {
			instance = { 'DTA', 'copyq' },
			name     = { 'Event Tester' },
			role     = { 'AlarmWindow', 'ConfigManager', 'pop-up'}
		},
		properties = { floating = true }
	},
	-- Fix requests_no_titlebar for someone clients
	{
		rule_any = {
			class = { "Xfce4-terminal"}
		},
		properties = { },
		callback = function(c)
			awful.titlebar.show(c)
		end
	}
}

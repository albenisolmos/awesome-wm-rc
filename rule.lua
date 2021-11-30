local awful = require('awful')
local shape = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local ruled     = require('ruled')

local clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function(c)
		client.focus = c
		c:raise()
		awesome.emit_signal('menu::hide')
		awesome.emit_signal('popup::hide')
	end),
	awful.button({'Mod4'}, 1, function(c)
		c:activate {
			context = 'titlebar',
			action = 'mouse_move'
		}
	end),
	awful.button({'Mod4'}, 3, function(c)
		c:activate {
			context = 'titlebar',
			action = 'mouse_resize'
		}
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

ruled.client.connect_signal('request::rules', function()
	ruled.client.append_rule {
		id = 'global',
		rule = { },
		properties = {
			focus        = awful.client.focus.filter,
			raise        = true,
			screen       = awful.screen.preferred,
			placement    = awful.placement.no_overlap+awful.placement.no_offscreen,
			size_hints_honor  = false,
			buttons = clientbuttons
		},
		callback = function(c)
			c.border_width = 0
			if c.requests_no_titlebar then
				awful.titlebar.hide(c)
			end
		end
	}

	ruled.client.append_rule {
		rule_any = { type = { 'normal', 'dialog'} },
		properties = { titlebars_enabled = true },
		callback = function(c)
			awful.placement.centered(c, {honor_padding = true, honor_workarea=true})
			c.border_width = beautiful.border_width
			c.border_color = beautiful.border_normal
		end
	}

	ruled.client.append_rule {
		rule_any = { type = { 'normal', 'dialog', 'splash', 'dock'} },
		callback = function(c)
			c.shape = function(cr, w, h)
				shape.rounded_rect(cr, w, h, dpi(8))
			end
		end
	}

	ruled.client.append_rule {
		id = 'floating',
		rule_any = {
			instance = { 'DTA', 'copyq' },
			name     = { 'Event Tester' },
			role     = { 'AlarmWindow', 'ConfigManager', 'pop-up'}
		},
		properties = { floating = true }
	}

	-- Fix requests_no_titlebar for someone clients
	ruled.client.append_rule {
		rule_any = {
			class = { "Xfce4-terminal"}
		},
		properties = { },
		callback = function(c)
			awful.titlebar.show(c)
		end
	}
end)

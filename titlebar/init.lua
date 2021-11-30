local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi

local windows_titlebar = require 'titlebar.windows'
local tab = require 'titlebar.tab'
local Menu = require 'widget.menu'
local current_client

awful.titlebar.enable_tooltip = false

local menu = Menu({
	items = {
		{'Close', function()
			current_client:kill()
		end},
		{'Minimize', function()
				current_client.minimized = false
		end},
		{'Maximize', function()
				current_client.maximized = not current_client.maximized
		end},
		{'Tabalize', function()
				tab.enable_tabs(current_client)
		end}
	}
})

client.connect_signal('request::titlebars', function(c)
	awful.titlebar(c, { size = 35 }).widget = windows_titlebar({
		awful.button({ }, 1, function()
			c:activate {
				context = 'titlebar',
				action = 'mouse_move'
			}
		end),
		awful.button({ }, 3, function()
			current_client = c
			menu:show()
			c:activate {
				context = 'titlebar',
				action = 'mouse_resize'
			}
		end)
	}, c)
end)

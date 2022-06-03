local amouse = require('awful.mouse')
local abutton = require('awful.button')
local atitlebar = require('awful.titlebar')
local dpi = require('beautiful').xresources.apply_dpi
local gtable = require('gears.table')

local windows_titlebar = require 'titlebar.windows'
--local tab = require 'titlebar.tab'
local Menu = require 'widget.menu'
local current_client

atitlebar.enable_tooltip = false

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
				--tab.enable_tabs(current_client)
		end}
	}
})

client.connect_signal('request::titlebars', function(c)
	atitlebar(c, { size = 35 }).widget = windows_titlebar(gtable.join(
		abutton({ }, 1, function()
			c:emit_signal("request::activate", "mouse_click", {raise = true})
			amouse.client.move(c)
		end),
		abutton({ }, 3, function()
			current_client = c
			menu:show()
			c:emit_signal("request::activate", "mouse_click", {raise = true})
			amouse.client.resize(c)
		end)
	), c)
end)

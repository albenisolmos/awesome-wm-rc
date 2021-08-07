local wibox        = require('wibox')
local awful        = require('awful')
local shape        = require('gears.shape')
local spawn        =  require('awful.spawn')
local beautiful    = require('beautiful')
local dpi          = beautiful.xresources.apply_dpi
local clickable    = require('widget.clickable')
local build_applet = require 'widget.applet'
local hotkeys_popup = require('awful.hotkeys_popup')

local menu_user = awful.menu({
	items = {
		{ 'Update desktop', function()
			awesome.emit_signal('desktop::update')
		end },
		{ 'Show icon desktop', function()
			screen.desktop.visible = not screen.desktop.visible
		end },
		{ 'Exit Screen', function()
			awesome.emit_signal('exitscreen::show')
		end },
		{ 'Help', function()
			hotkeys_popup.show_help( nil, awful.screen.focused() )
		end }
	}
})

local applet = build_applet(wibox.widget {
	id = 'user',
	layout    = clickable,
	bg = beautiful.bg_medium_trans,
	fg        = beautiful.fg_soft_focus,
	bg        = beautiful.transparent,
	bg_normal = beautiful.transparent,
	bg_hover  = beautiful.bg_hover,
	bg_press  = beautiful.bg_press,
	shape     = shape.rounded_bar,
	{
			widget = wibox.widget.imagebox,
			image = beautiful.icon_user,
	}
},
function() menu_user:toggle() end,
function() end)

return applet

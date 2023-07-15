local atag = require('awful.tag')
local alayout = require('awful.layout')
local beautiful = require('beautiful')

local function new_tag(name, screen, icon, layout, bool)
	return atag.add(name, {
		icon               = icon,
		layout             = layout,
		master_fill_policy = 'master_width_factor',
		gap_single_client  = true,
		gap                = 0,
		screen             = screen,
		selected           = bool or false,
	})
end

screen.connect_signal('request::desktop_decoration', function(s)
	new_tag('1', s, beautiful.icon_taglist_home, alayout.suit.floating, true)
	new_tag('2', s, beautiful.icon_taglist_development, alayout.suit.floating)
	new_tag('3', s, beautiful.icon_taglist_web_browser, alayout.suit.floating)
end)

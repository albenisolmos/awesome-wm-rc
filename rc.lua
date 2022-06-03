require('awful.autofocus')
require('awful.ewmh')
require('utils.table')

local spawn = require('awful.spawn')
local amouse = require('awful.mouse')
local abutton = require('awful.button')
local autil = require('awful.util')
local atag = require('awful.tag')
local ascreen = require('awful.screen')
local alayout = require('awful.layout')
local gtable = require('gears.table')
local gwallpaper = require('gears.wallpaper')
local beautiful = require('beautiful')
local naughty = require('naughty')
local dir = require('gears.filesystem').get_configuration_dir()
local hotcorner = require('display.hot-corners')

require('error')

-- Preferences --
require('preferences')
autil.shell = _G.preferences.shell
amouse.snap.edge_enabled = false
amouse.snap.client_enabled = false
awesome.set_preferred_icon_size(64)

-- On init --
beautiful.init(string.format('%s/themes/%s.lua', dir,  _G.preferences.theme))
for _, command in pairs(_G.preferences.once_spawn) do
	spawn.once(command)
end
require('client').init()
require('signals')
require('titlebar')
require('notifications')
require('rules')
require('apps.dock')
--local Tab = require 'titlebar.tab'
--Tab.init()
root.keys(require('global-keys'))

local function set_wallpaper(s)
	if _G.preferences.wallpaper then
		local wallpaper = _G.preferences.wallpaper

		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end

		if wallpaper[0] == '#' then
			gwallpaper.set(wallpaper)
		else
			gwallpaper.maximized(wallpaper, s, true)
		end
	end
end
screen.connect_signal("property::geometry", set_wallpaper)

local function set_tag(name, screen, icon, layout, bool)
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

ascreen.connect_for_each_screen(function(s)
	set_wallpaper(s)

	set_tag('1', s, beautiful.icon_taglist_home, alayout.suit.floating, true)
	set_tag('2', s, beautiful.icon_taglist_development, alayout.suit.floating)
	set_tag('3', s, beautiful.icon_taglist_web_browser, alayout.suit.floating)

	s.exitscreen = require('display.exit-screen')(s)
	s.switcher   = require('display.switcher')(s)
	s.runner     = require('display.runner')(s)
	s.topbar     = require('display.topbar')(s)
	s.popup      = require('display.popup')(s)

	hotcorner {
		screen = s,
		position = 'bottom',
		callback = function()
			awesome.emit_signal('dock::partial_show')
		end
	}

	hotcorner {
		screen = s,
		position = 'top',
		callback = function()
			awesome.emit_signal('topbar::partial_show')
		end
	}
end)

root.buttons(gtable.join(
	abutton({ }, 1, function()
		awesome.emit_signal('popup::hide')
		awesome.emit_signal('menu::hide')
	end)
))

--
-- Extras Functions
--

awesome.connect_signal('hotkeys::show', function()
	require('awful.hotkeys_popup').show_help()
end)

local last_coords = { x = 0, y = 0}
amouse.resize.add_enter_callback(function(c)
	last_coords.x = c.x
	last_coords.y = c.y
end, 'mouse.move')

amouse.resize.add_leave_callback(function(c)
	if (not c.floating)
		and alayout.get(c.screen) ~= alayout.suit.floating
		or c.type == 'dialog'
		then
		return
	end

	local coords = mouse.coords()
	local sg = c.screen.geometry
	local sw = c.screen.workarea
	local snap = amouse.snap.default_distance

	if coords.x > snap + sg.x
		and coords.x < sg.x + sg.width - snap
		and coords.y <= snap + sg.y
		and coords.y >= sg.y
		then
		c.maximized = true
		c:raise()
	elseif coords.x > snap + sg.x
		and coords.x < sg.x + sg.width - snap
		and coords.y >= sg.height - snap
		and coords.y <= sg.height
		then
		c.minimized = true
		c.x = last_coords.x
		c.y = last_coords.y
	elseif coords.x == 0 then
		c.x = 0
		c.y = sw.y
		c.width = sg.width / 2
		c.height = sg.height - sw.y
	elseif coords.x >= sg.width - snap then
		c.x = sg.width - c.width
		c.y = sw.y
		c.width = sg.width / 2
		c.height = sg.height - sw.y
	end
end, "mouse.move")

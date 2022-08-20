require('awful.autofocus')
require('awful.ewmh')
require('utils.table')
require('error')

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
local dir = require('gears.filesystem').get_configuration_dir()
local hotcorner = require('display.hot-corners')

-- Preferences --
require('settings')
autil.shell = SETTINGS.shell
amouse.snap.edge_enabled = false
amouse.snap.client_enabled = false
awesome.set_preferred_icon_size(64)

-- On init --
beautiful.init(string.format('%s/themes/%s.lua', dir,  SETTINGS.theme))
for _, command in pairs(SETTINGS.once_spawn) do
	spawn.once(command)
end
require('signals')
require('modules.titlebar')
require('notifications')
require('rules')
local keymaps = require('keymaps')

local trigger_in_screen = {}
function trigger_module(module)
	local opts = require('modules.'..module).init()

	if not opts then return end
	for opt, callback in pairs(opts) do
		if opt == 'on_keymaps' then
			keymaps.add(callback())
		elseif opt == 'on_screen' then
			table.insert(trigger_in_screen, callback)
		end
	end
end

trigger_module('client')
trigger_module('dock')

local function set_wallpaper(s)
	if SETTINGS.wallpaper then
		local wallpaper = SETTINGS.wallpaper

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

	s.switcher   = require('display.switcher')(s)
	s.runner     = require('display.runner')(s)
	s.topbar     = require('display.topbar')(s)
	s.popup      = require('display.popup')(s)

	-- Trigger modules on screen
	for _, callback in pairs(trigger_in_screen) do
		callback(s)
	end
end)

root.keys(keymaps.init())
root.buttons(gtable.join(
	abutton({ }, 1, function()
		awesome.emit_signal('popup::hide')
		awesome.emit_signal('menu::hide')
	end)
))

_G.awesome_is_ready = true

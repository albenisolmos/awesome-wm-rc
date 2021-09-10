require('preferences')

local awful     = require('awful')
local wibox     = require('wibox')
local gears     = require('gears')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local naughty   = require('naughty')
local hotkeys   = require('awful.hotkeys_popup')
local dpi       = beautiful.xresources.apply_dpi
local dir       = gears.filesystem.get_configuration_dir()

awesome.connect_signal('debug::error', function(err)
	naughty.notification {
		title = 'Debug::Error', text = tostring(err)
	}
end)

-- Preferences
awful.util.shell = _G.preferences.shell
awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = false
-- Start Apps in the startup
awful.spawn.once('picom')
awful.spawn.once('/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1')

if _G.preferences.desktop_icon then
	awful.spawn.once('nautilus-desktop', {
			sticky = true,
			skip_taskbar = true
		})
end

beautiful.init(dir .. '/themes/' .. _G.preferences.theme .. '.lua')

-- Titlebar
require('titlebars.'.. _G.preferences.titlebar_style)
require 'notifications'
require 'keys'
require 'rule'
require 'global'

--
-- Wallpaper
--
screen.connect_signal("request::wallpaper", function(s)
	if _G.preferences.wallpaper then
		local wallpaper = _G.preferences.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		elseif wallpaper[0] == '#' then
			gears.wallpaper.set(beautiful.wallpaper_color)
		else
			gears.wallpaper.maximized(wallpaper, s, true)
		end
	end
end)

local function set_tag(name, screen, icon, layout, bool)
	return awful.tag.add(name, {
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
	-- Tag
	set_tag('1', s, beautiful.icon_taglist_home, awful.layout.suit.floating, true)
	set_tag('2', s, beautiful.icon_taglist_development, awful.layout.suit.floating)
	set_tag('3', s, beautiful.icon_taglist_web_browser, awful.layout.suit.floating)

	-- Desktop Components
	s.exitscreen = require 'display.exit-screen'(s)
	s.switcher   = require 'display.switcher'(s)
	s.dock       = require 'display.dock'(s)
	s.dialog     = require 'display.dialog'(s)
	s.hotcorners = require 'display.hot-corners'(s)
	s.topbar     = require 'display.topbar'(s)
	s.popup      = require 'display.popup'(s)
end)

--
-- Layouts
--[[
tag.connect_signal('request::default_layouts', function()
	awful.layout.append_default_layouts({
		awful.layout.suit.floating,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.spiral,
	})
end)
]]--

naughty.connect_signal("request::display_error", function(message, startup)
	naughty.notification {
		urgency = "critical",
		title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
		message = message,
		app_name = 'Awesome',
		icon = beautiful.awesome_icon
	}
end)

root.buttons({ 
	awful.button({ }, 1, function()
		awesome.emit_signal('popup::hide')
	end)
})

--
-- Extras Functions
--

local function fullscreen_or_maximized(c)
	if c.fullscreen or c.maximized then
		c.shape = shape.rectangle
		c.border_width = 0
	else
		c.shape = function(cr, w, h)
			shape.rounded_rect(cr, w, h, dpi(8))
		end
	end
end

local function ontiled_client(c)
	if c.floating then
		c.shape = function(cr, w, h)
			shape.rounded_rect(cr, w, h, dpi(8))
		end
	else
		c.shape = shape.rectangle
	end
end

local function ontiled_clients(t)
	awesome.emit_signal('topbar::update')
	for _, c in pairs(t:clients()) do
		ontiled_client(c)
	end
end

--
-- Signals
--
-- c:set_xproperty('_NET_WM_STATE_FOCUSED')
awesome.register_xproperty('_NET_WM_NAME', 'string')
awesome.register_xproperty('_NET_WM_STATE_FOCUSED', 'boolean')
client.connect_signal('property::active', function(c)
	if c.active then
		awful.spawn('xprop -set _NET_WM_STATE_FOCUSED true -id ' .. c.window)
	else
		awful.spawn('xprop -remove _NET_WM_STATE_FOCUSED -id ' .. c.window)
	end
end)

tag.connect_signal('property::layout', ontiled_clients)

client.connect_signal('property::fullscreen', fullscreen_or_maximized)
client.connect_signal('property::maximized', fullscreen_or_maximized)
client.connect_signal('property::floating', ontiled_client)
client.connect_signal('request::manage', function(c)
	if awesome.startup and
		not c.size_hints.user_position
		and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
end)

awesome.connect_signal('hotkeys::show', function()
	hotkeys.show_help()
end)

screen.emit_signal('tag::history::update')

local last_coords = {x=0, y=0}

awful.mouse.resize.add_enter_callback(function(c, _, args)
	last_coords.x = c.x
	last_coords.y = c.y
end, 'mouse.move')

awful.mouse.resize.add_leave_callback(function(c, _, args)
	if (not c.floating)
		and awful.layout.get(c.screen) ~= awful.layout.suit.floating
		then
		return
	end

	local coords = mouse.coords()
	local sg = c.screen.geometry
	local snap = awful.mouse.snap.default_distance

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
	end
end, "mouse.move")

local awful     = require('awful')
local gears     = require('gears')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local naughty   = require('naughty')
local hotkeys   = require('awful.hotkeys_popup')
local dpi       = beautiful.xresources.apply_dpi
local dir       = gears.filesystem.get_configuration_dir()

-- Preferences
require('preferences')
awful.util.shell = _G.preferences.shell
awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = false
awesome.set_preferred_icon_size(64)

-- On init
beautiful.init(dir .. '/themes/' .. _G.preferences.theme .. '.lua')
for _, command in pairs(_G.preferences.once_spawn) do
	awful.spawn.once(command)
end

require 'titlebar'
require 'notifications'
require 'keys'
require 'rule'
require 'signals'
local Tab = require 'titlebar.tab'
Tab.init()

--
-- Wallpaper
--
screen.connect_signal("request::wallpaper", function(s)
	if _G.preferences.wallpaper then
		local wallpaper = _G.preferences.wallpaper

		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end

		if wallpaper[0] == '#' then
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
	s.runner     = require 'display.runner'(s)
	s.hotcorners = require 'display.hot-corners'(s)
	s.topbar     = require 'display.topbar'(s)
	s.popup      = require 'display.popup'(s)
end)

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
		awesome.emit_signal('menu::hide')
	end)
})

--
-- Extras Functions
--

local function fullscreen_or_maximized(c)
	if c.maximized then
		c.shape = function(cr, w, h)
			shape.rounded_rect(cr, w, h, dpi(8), dpi(8), 0, 0)
		end
		c.border_width = 0
	elseif c.fullscreen then
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

--screen.emit_signal('tag::history::update')

local last_coords = {x=0, y=0}
awful.mouse.resize.add_enter_callback(function(c)
	last_coords.x = c.x
	last_coords.y = c.y
end, 'mouse.move')

awful.mouse.resize.add_leave_callback(function(c)
	if (not c.floating)
		and awful.layout.get(c.screen) ~= awful.layout.suit.floating
		then
		return
	end

	local coords = mouse.coords()
	local sg = c.screen.geometry
	local sw = c.screen.workarea
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

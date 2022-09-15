local spawn = require('awful.spawn')
local amouse = require('awful.mouse')
local wibox = require('wibox')
local alayout = require('awful.layout')
local shape = require('gears.shape')
local dpi = require('beautiful').xresources.apply_dpi
local last_coords = { x = 0, y = 0}
local M = {}

local function on_fullscreen(cli)
	if cli.fullscreen then
		cli.shape = shape.rectangle
	else
		M.restore_client(cli)
	end
end

local function on_maximized(cli)
	if cli.maximized then
		local rounded = dpi(SETTINGS.client_rounded_corner_on_maximized
			and SETTINGS.client_rounded_corners or 0)
		cli.shape = function(cr, w, h)
			shape.rounded_rect(cr, w, h, rounded, rounded, 0, 0)
		end
	else
		M.restore_client(cli)
	end
end

local function on_tiled_client(cli)
	if cli.floating then
		M.restore_client(cli)
	else
		cli.shape = shape.rectangle
	end
end

local function on_tiled_clients(t)
	awesome.emit_signal('topbar::update')
	for _, cli in pairs(t:clients()) do
		on_tiled_client(cli)
	end
end

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

function M.restore_client(cli)
	cli.shape = function(cr, w, h)
		shape.rounded_rect(cr, w, h, dpi(SETTINGS.client_rounded_corners))
	end
	cli.border_width = SETTINGS.client_border_width
end

function M.init(screen)
	awesome.register_xproperty('_NET_WM_NAME', 'string')
	awesome.register_xproperty('_NET_WM_STATE_FOCUSED', 'boolean')

	client.connect_signal('request::activate', function(c)
		if c.active then
			spawn('xprop -set _NET_WM_STATE_FOCUSED true -id ' .. c.window)
		else
			spawn('xprop -remove _NET_WM_STATE_FOCUSED -id ' .. c.window)
		end
	end)

	client.connect_signal('property::fullscreen', on_fullscreen)
	client.connect_signal('property::maximized', on_maximized)
	client.connect_signal('property::floating', on_tiled_client)
	tag.connect_signal('property::layout', on_tiled_clients)

	return {
		on_keymaps = function()
			return require('modules.client.keymaps')()
		end,
		on_screen = function(screen)
			return require('modules.client.screen')(screen)
		end
	}
end

return M

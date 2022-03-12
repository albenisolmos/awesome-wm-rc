local spawn = require('awful.spawn')
local shape = require('gears.shape')
local dpi = require('beautiful').xresources.apply_dpi
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
		local rounded = dpi(_G.preferences.client_rounded_corner_on_maximized
			and _G.preferences.client_rounded_corners or 0)
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

function M.restore_client(cli)
	cli.shape = function(cr, w, h)
		shape.rounded_rect(cr, w, h, dpi(_G.preferences.client_rounded_corners))
	end
	cli.border_width = _G.preferences.client_border_width
end

function M.init()
	awesome.register_xproperty('_NET_WM_NAME', 'string')
	awesome.register_xproperty('_NET_WM_STATE_FOCUSED', 'boolean')

	client.connect_signal('property::active', function(c)
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
	client.connect_signal('request::manage', function(c)
		if awesome.startup and
			not c.size_hints.user_position and
			not c.size_hints.program_position then
			placement.no_offscreen(c)
		end
	end)
end

return M

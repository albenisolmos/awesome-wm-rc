local awful = require('awful')
local wibox = require('wibox')
local keygrabber = require('awful.keygrabber')

local Tab = {}
local all_witabs = {}
local all_current_clients = {}

function awful.client.object.set_witab(cli, witab)
	cli._witab = witab 
	cli:emit_signal('property::witab')
end

function awful.client.object.get_witab(self)
	return self._witab
end

local function tab_widget_new(c)
	return wibox.widget {
		layout = wibox.layout.align.horizontal,
		awful.titlebar.widget.iconwidget(c),
		awful.titlebar.widget.titlewidget(c),
		nil
	}
end

local function get_spawn_cmd(cli)
	return string.lower(cli.class)
end

local function syncronize(cli, witab)
	cli:connect_signal('property::geometry', function(c)
		local geo = c:geometry()
		witab:geometry({
			x = geo.x,
			y = geo.y - 35,
			width = geo.width,
			height = 35
		})
	end)
end

local function tab_new(cli, is_first_tab)
	cli = cli or client.focus
	local witab = cli.witab
	witab.focused_client = cli

	awful.titlebar.hide(cli)
	syncronize(cli, witab)

	if not is_first_tab then
		awful.spawn(get_spawn_cmd(cli), {callback = function(c) cli = c end})
		table.insert(witab.clients, cli)
	end

	witab.widget:add(tab_widget_new(cli))
end

function Tab.enable_tabs(cli)
	if not cli then return error ('No client provided')end

	local container = wibox.layout.fixed.horizontal()
	local witab = wibox {
		screen = cli.screen,
		width = cli.width,
		height = 35,
		y = cli.y - 35,
		x = cli.x,
		visible = true,
		bg = '#212121',
		widget = container,
	}
	witab.clients = {cli}
	witab.focused_client = nil

	cli.witab = witab
	table.insert(all_witabs, witab)
	tab_new(cli, true)
end

function Tab.init()
	keygrabber {
		mask_event_callback = true,
		export_keybinding = true,
		stop_key = 'Mod4',
		stop_event = 'release',
		start_callback = function()
		end,
		stop_callback = function()
		end,
		root_keybindings = {
			awful.key {
				modifiers = {'Mod4'},
				key = 'y',
				on_press = tab_new
			}
		}
	}
end

return Tab

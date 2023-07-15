local aclient = require('awful.client')
local atitlebar = require('awful.titlebar')
local abutton = require('awful.button')
local akey = require('akey')
local spawn = require('awful.spawn')
local keygrabber = require('akeygrabber')
local wibox = require('wibox')
local gtable = require('gears.table')
local clickable = require('widgets.clickable')

local Tab = {}

function aclient.object.set_witab(cli, witab)
	cli._witab = witab 
	cli:emit_signal('property::witab')
end

function aclient.object.get_witab(self)
	return self._witab
end

local function tab_widget_new(c, witab)
	local widget = wibox.widget {
		widget = clickable,
		{
			layout = wibox.layout.align.horizontal,
			atitlebar.widget.iconwidget(c),
			atitlebar.widget.titlewidget(c),
			nil
		}
	}

	widget:buttons(gtable(
		abutton({}, 1, function()
			witab:focus_client(c)
		end)
	))

	return widget
end

local function get_spawn_cmd(cli)
	return string.lower(cli.class)
end

local function find_index(tbl, target)
	for i, el in pairs(tbl) do
		if el == target then return i end
	end
end

local function syncronize(cli, witab)
	atitlebar.hide(cli)
	cli:connect_signal('property::geometry', function(c)
		local geo = c:geometry()
		witab:geometry({
			x = geo.x,
			y = geo.y - 35,
			width = geo.width,
			height = 35
		})
	end)

	cli:connect_signal('unmanage', function(c)
		tab_close(c, true)
	end)
end

local function tab_close(cli, no_kill_cli)
	local index = find_index(cli.witab.clients, cli)
	cli.witab.widget:remove(index)

	if not no_kill_cli then
		cli:kill()
	end
end

local function tab_new(cli, is_first_tab)
	cli = cli or client.focus
	local witab = cli.witab
	local function on_new()
		syncronize(cli, witab)
		table.insert(witab.clients, cli)
		witab:focus_client(cli)
		witab.widget:add(tab_widget_new(cli, witab))
	end

	if not is_first_tab then
		spawn(
			get_spawn_cmd(cli),
			{ callback = function(c)
				cli = c
				cli.witab = witab
				on_new()
			end }
		)
	else
		on_new()
	end
end

local function for_each(tbl, step)
	if not tbl or not step then return end
	for i, el in pairs(tbl) do
		step(el, i)
	end
end

local function tab_focus(target)
	if type(target) == 'number' then
		local curr_cli = client.focus
		local index = find_index(curr_cli.witab.clients, curr_cli)
		local cli = curr_cli.witab.clients[target]

		if index ~= target and cli then
			curr_cli.witab:focus_client(cli)
		end
	end
end

function Tab.enable_tabs(cli)
	if not cli then return error('No client provided') end

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
	witab.clients = {}
	witab.focused_client = nil

	function witab:focus_client(c)
		if self.focused_client == c then
			return
		elseif self.focused_client then
			self.focused_client.hidden = true
		end

		c.hidden = false
		self.focused_client = c
	end

	cli.witab = witab
	tab_new(cli, true)

	keygrabber {
		export_keybinding = true,
		stop_key = 'Mod4',
		stop_event = 'release',
		start_callback = function()
		end,
		stop_callback = function()
		end,
		root_keybindings = {
			akey {
				modifiers = {'Mod4', 'Mod1'},
				keygroup = 'numrow',
				on_press = tab_focus
			}
		}
	}
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
			akey {
				modifiers = {'Mod4'},
				key = 'y',
				on_press = tab_new
			}
		}
	}
end

return Tab

local tag = require('awful.tag')
local akey = require('awful.key')
local spawn = require('awful.spawn')
local ascreen = require('awful.screen')
local aclient = require('awful.client')
local gtable = require('gears.table')
local gshape = require('gears.shape')

local uclient = require('utils.client')
local utable = require('utils.table')
local settings = require('settings')

local M = {}
local keymaps = {}
local modkey = settings.modkey

function M.init()
	keymaps = gtable.join(keymaps,
	akey({modkey, 'Shift'}, 'm', function()
		local c = aclient.restore()
		-- Focus restored client
		if c then
			c:activate { raise = true, context = "key.unminimize" }
		end
	end, { description = 'Unminimize client', group = 'Client' }),

	akey({modkey, 'Control'}, 'm', function()
		uclient.minimize_all()
	end, { description = '(Un)minimize all', group = 'Client' }),

	akey({ modkey, 'Control' }, 'r', function()
		awesome.restart()
	end, { description = 'Reload awesome', group = 'Awesome' }),
	akey({ modkey }, 'i', function()
		awesome.emit_signal('hotkeys::show')
	end, { description = 'Show help', group = 'Awesome' }),
	--key({ modkey }, 'space', function()
	--	awesome.emit_signal('runner::run', 'run')
	--end, { description = 'Open Runner', group = 'Awesome' }),
	akey({ modkey }, 'p', function()
		spawn.with_shell(settings.cmd_player_pause)
	end, { description = 'Play/Pause music player', group = 'System'}),
	akey({ modkey }, ']', function()
		awesome.emit_signal('sound::level', '+5%')
	end, { description = 'Increase volume level', group = 'System'}),
	akey({ modkey }, '[', function()
		awesome.emit_signal('sound::level', '-5%')
	end, { description = 'Decrease volume level', group = 'System'}),
	akey({}, 'Print', function()
		spawn.easy_async_with_shell('scrot -e "xclip -selection clipboard -t image/png -i $f"')
	end, { description='Take a Screenshot', group = 'System' }),
	akey({ 'Mod1' }, 'Print', function()
		spawn('scrot -s "xclip -selection clipboard -t image/png -i $f"')
	end, { description='Take a Rectangle Screenshot', group = 'Launch' }),
	akey({ modkey }, 'Return', function()
		spawn(settings.terminal)
	end, { description = 'Open a terminal', group = 'System' }),
	akey({ modkey }, 'r', function()
		spawn(settings.launcher)
	end, { description = 'Apps launcher', group = 'System' }),
	akey({ modkey }, 'p', function() tag.viewprev() end,
	{ description = 'Go to previous tag', group = 'Tag' }),
	akey({ modkey }, 'b', function() tag.viewnext() end,
	{ description = 'Go to next tag', group = 'Tag' }),
	akey({ modkey }, 'Left', function() tag.viewprev() end,
	{ description = 'Go to previous tag', group = 'Tag' }),
	akey({ modkey  }, 'Right', function() tag.viewnext() end,
	{ description = 'Go to next tag', group = 'Tag' }),
	akey({ modkey, 'Control' }, 'd', function()
		local t = screen.focused().selected_tag
		tag.incgap(-5, t)
		if t.gap == 0 then
			for _, c in pairs(t:clients()) do
				if not c.floating then
					c.shape = gshape.rectangle
				end
			end
		end
	end, { description = 'Increase spacing between clients', group = 'Tag'}),
	akey({ modkey, 'Control' }, 'a', function()
		tag.incgap(5)
	end, { description = 'Increase spacing between clients', group = 'Tag'})
	)

	local function selected_client_by_index(index)
		local clients = utable.filter(
            uclient.get_clients_in_tags(),
            uclient.is_displayable
		)

		local cli = clients[index]
		if cli then
			client.focus = cli
			cli:raise()
		end
	end

	local function view_tag(i)
		local screen = ascreen.focused()
		local tag = screen.tags[i]
		if tag then
			tag:view_only()
		end
	end

	for i=1, 9 do
		keymaps = gtable.join(keymaps,
		akey({ modkey, 'Shift' }, '#' .. i + 9, function()
			selected_client_by_index(i)
		end, { description = 'Select client by index', group = 'Client'}),

		akey({ modkey }, '#' .. i + 9, function()
			view_tag(i)
		end, { description = 'only view tag', group = 'Tag'}),

		akey({ modkey, 'Control' }, '#' .. i + 9, function()
			if client.focus then
				local c = client.focus
				local tag = c.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, {description = 'Move focused client to tag', group = 'Tag'})
		)
	end

	return keymaps
end

function M.add(_keymaps)
	keymaps = gtable.join(keymaps, _keymaps)
end

return M

local key = require('awful.key')
local spawn = require('awful.spawn')
local titlebar = require('awful.titlebar')
local client = require('awful.client')
local gtable = require('gears.table')

local modkey = _G.preferences.modkey

return gtable.join(
	key({ modkey }, 'ñ',  function(c)
		spawn.easy_async('xprop -id ' .. c.window, function(stdout)
			naughty.notification {
				title = 'notif',
				message = stdout,
				timeout = 0
			}
		end)
	end, { description = 'toggle floating', group = 'client' }),

	key({ modkey }, 'f',  client.floating.toggle,
	{ description = 'toggle floating', group = 'client' }),

	key({ modkey }, 'g', function(c)
		c.ontop = not c.ontop
	end, { description = 'toggle keep on top', group = 'client' }),

	key({ modkey }, 'y', function(c)
		c.sticky = not c.sticky
		c:raise()
	end, { description = 'Toggle keep on sticky', group = 'client' }),

	key({ modkey }, 'q', function(c)
		c:kill()
	end, { description = 'close', group = 'client' }),

	key({ modkey }, 's', function(c)
		c.minimized = true
	end, { description = 'Toggle minimize', group = 'client' }),

	key({ modkey }, 'w', function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = 'Toggle maximize', group = 'client' }),

	key({ modkey, 'Control' }, 'w', function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = 'Toggle fullscreen', group = 'client' }),

	key({ modkey }, 't', titlebar.toggle,
		{ description = 'Toggle  titlebar', group = 'client' })
)

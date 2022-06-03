local spawn = require('awful.spawn')
local akey = require('awful.key')
local aclient = require('awful.client')
local atitlebar = require('awful.titlebar')
local naughty = require('naughty')
local pic_path = '/Pictures/'
local modkey = 'Mod4'

require('awful.autofocus')

client.connect_signal('request::default_keybindings', function()
	akeyboard.append_client_keybindings({
		akey({ modkey }, 'ñ',  function(c)
			awful.spawn.easy_async('xprop -id ' .. c.window, function(stdout)
				naughty.notification {
					title = 'notif',
					message = stdout,
					timeout = 0
				}
			end)
		end,
		{ description = 'toggle floating', group = 'client' }),

		akey({ modkey }, 'f',  aclient.floating.toggle,
		{ description = 'toggle floating', group = 'client' }),

		akey({ modkey }, 'g', function(c)
			c.ontop = not c.ontop
		end,
		{ description = 'toggle keep on top', group = 'client' }),

		akey({ modkey }, 'y', function(c)
			c.sticky = not c.sticky
			c:raise()
		end,
		{ description = 'Toggle keep on sticky', group = 'client' }),

		akey({ modkey }, 'q', function(c) c:kill() end,
		{ description = 'close', group = 'client' }),

		akey({ modkey }, 's', function(c)
			c.minimized = true
		end,
		{ description = 'Toggle minimize', group = 'client' }),

		akey({ modkey }, 'w', function (c)
			c.maximized = not c.maximized
			c:raise()
		end,
		{ description = 'Toggle maximize', group = 'client' }),

		akey({ modkey, 'Control' }, 'w', function (c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{ description = 'Toggle fullscreen', group = 'client' }),

		akey({ modkey }, 't', atitlebar.toggle,
		{ description = 'Toggle  titlebar', group='client' })
	})
end)


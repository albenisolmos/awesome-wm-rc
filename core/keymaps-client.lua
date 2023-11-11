local akey = require('awful.key')
local atitlebar = require('awful.titlebar')
local aclient = require('awful.client')
local gtable = require('gears.table')
local uclient = require('utils.client')
local settings = require('settings')

local modkey = settings.modkey

return gtable.join(
	akey({ modkey }, 'm', function(c)
		c.minimized = true
	end, { description = 'Minimize client', group = 'Client' }),

	akey({modkey}, 'Escape', function()
        require('utils.debug').log('ESCAPE')
		uclient.unminimize_all()
	end, { description = 'unminimize_all', group = 'Client' }),

	akey({ modkey }, 'w', function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = 'Toggle maximize', group = 'Client' }),

	akey({ modkey }, 'q', function(c)
		c:kill()
	end, { description = 'Close client', group = 'Client' }),

	akey({ modkey, 'Control' }, 'w', function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = 'Toggle fullscreen', group = 'Client' }),

	akey({modkey}, 'f',  aclient.floating.toggle,
	{ description = 'toggle floating', group = 'Client' }),

	akey({modkey}, 't', function(c)
		c.ontop = not c.ontop
	end, { description = 'toggle keep on top', group = 'Client' }),

	akey({ modkey }, 'y', function(c)
		c.sticky = not c.sticky
		c:raise()
	end, { description = 'Toggle keep on sticky', group = 'Client' }),

	akey({modkey, 'Shift'}, 't', atitlebar.toggle,
		{ description = 'Toggle titlebar', group = 'Client' })
)

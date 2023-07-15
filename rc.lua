require('awful.autofocus')
require('awful.ewmh')

local spawn = require('awful.spawn')
local amouse = require('awful.mouse')
local abutton = require('awful.button')
local autil = require('awful.util')
local gtable = require('gears.table')
local beautiful = require('beautiful')
local dir = require('gears.filesystem').get_configuration_dir()

local settings = require('settings').init()
-- init theme
beautiful.init(string.format('%s/themes/%s/init.lua', dir,  settings.theme))


require('core')
require('modules')

autil.shell = settings.shell
amouse.snap.edge_enabled = false
amouse.snap.client_enabled = false
awesome.set_preferred_icon_size(64)

-- once spawn defined apps
for _, command in pairs(settings.once_spawn) do
	spawn.once(command)
end


local keymaps = require('keymaps')

--require('awful').keyboard.append_global_keybindings({keymaps.init()})
root.keys=keymaps.init()
root.buttons=gtable.join(
	abutton({ }, 1, function()
		awesome.emit_signal('popup::hide')
		awesome.emit_signal('menu::hide')
	end)
)

_G.awesome_is_ready = true

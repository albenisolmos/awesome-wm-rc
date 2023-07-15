local keymaps = require('keymaps')
local settings = require('settings')
local trigger_in_screen = {}

local function trigger_module(name)
	local module = require('modules.'..name)

	if not module then return end
	for key, callback in pairs(module) do
		if key == 'init' then
			callback()
		elseif key == 'on_keymaps' then
			keymaps.add(callback())
		elseif key == 'on_screen' then
			table.insert(trigger_in_screen, callback)
		end
	end
end

trigger_module('client')
trigger_module('wallpaper')
trigger_module('titlebar')
trigger_module('popup')
trigger_module('wibar')
trigger_module('switcher')
--trigger_module('snap')
trigger_module('dock')
if settings.test then
    trigger_module('test')
end

screen.connect_signal('request::desktop_decoration', function(s)
	for _, callback in pairs(trigger_in_screen) do
		callback(s)
	end
end)

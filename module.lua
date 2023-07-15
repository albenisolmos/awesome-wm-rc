local keymaps = require('keymaps')
local settings = require('settings')
local trigger_in_screen = {}
local M = {}

function M.run(path)
	local module = require(path)

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

screen.connect_signal("request::desktop_decoration", function(s)
	-- Trigger modules on screen
	for _, callback in pairs(trigger_in_screen) do
		callback(s)
	end
end)

return M

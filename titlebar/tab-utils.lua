local awful = require('awful')
local Tab = {}

Tabs.all_tabs = {}

function Tab.enable_tabs(c)
	c.tabbed = true
end

local function tab_new()
	if client.focus.tabbed then
		_G.print('TABBB')
	end
end

awful.keygrabber {
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

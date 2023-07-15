local aplacement = require('awful.placement')
local aspawn = require('awful.spawn')

local settings = require('settings')
local udock = require('modules.dock.utils')
local M = {}
local disable_module

function M.on_screen(s)
	if disable_module then return end
	require('display.hot-corners') {
		screen = s,
		position = 'bottom',
		callback = function()
			awesome.emit_signal('dock::show_temporarily')
		end
	}
end

function M.init()
	if settings.wibar_position == settings.dock_position then
		disable_module = true
		aspawn.with_shell('killall olmos-dock')
		return
	end

	aspawn.single_instance('olmos-dock', {
		placement = function(dock)
			local place = aplacement.centered + aplacement.bottom
			place(dock, {margins = settings.dock_gap})
		end,
		skip_taskbar = true,
		sticky = true,
		callback = function(dock)
			require('modules.dock.utils').init(dock)

			tag.connect_signal('property::layout', udock.update)
			awesome.connect_signal('dock::kill', udock.kill)
			awesome.connect_signal('dock::property::hide', udock.set_hiding_type)

			awesome.emit_signal('dock::property::hide', settings.dock_hide)
		end
	})
end

return M

local placement = require('awful.placement')
local spawn = require('awful.spawn')

return { init = function()
	spawn.single_instance('olmos-dock', {
		placement = placement.bottom + placement.center,
		skip_taskbar = true,
		sticky = true,
		callback = function(dock)
			require('modules.dock.hiding_behavior')(dock)
			awesome.emit_signal('dock::hiding_behavior', SETTINGS.dock_hiding_behavior)
		end})

		return {
			on_screen = function(s)
				require('display.hot-corners') {
					screen = s,
					position = 'bottom',
					callback = function()
						awesome.emit_signal('dock::partial_show')
					end
				}
			end
		}
	end
}

local icon_path = '/usr/share/icons/Papirus/32x32/apps/'
local app_path  = '/usr/share/applications/'
local apps_cache = require('gears').filesystem.get_configuration_dir() .. '/cache/dock'

local utils = {}
--[[
function utils.get_output(command)
	local output
	command = io.popen(command)
	output = command:read('*all')
	command:close()

	return output
end
]]
function utils.save_app(app)
	local apps = io.open(apps_cache, 'a')
	apps:write(app, '\n')
	apps:close()
end

function utils.search_app(app, bool)
	local app_file, content, icon, exec, terminal, name

	local posible_app_file = io.popen('find '..app_path.. ' -maxdepth 1 -iname *' ..app..'*' )
	for file in posible_app_file:lines() do
		app_file = io.open(file, 'r')
		break
	end
	posible_app_file:close()
	if not app_file then
		return
	end
	content = app_file:read('*all')
	app_file:close()

	name = content:match('Name=(.-)\n')
	icon = content:match('Icon=(.-)\n')

	exec = content:match('TryExec=(.-)\n')
	if exec == nil then
		exec = content:match('Exec=(.-)\n'):gsub('(%%.)', '')
	end

	terminal = content:match('Terminal=(.-)\n')
	if terminal == 'true' then
		exec = _G.preferences.terminal .. ' -e' .. exec
	end

	awesome.emit_signal('dock::item', {
		icon    = string.format('%s%s.svg', icon_path, icon),
		onclick = exec,
		name    = name
	})

	if bool == true then
		utils.save_app(app)
	end
end

function utils.remember_apps()
	local apps = io.open(apps_cache, 'r')
	for app in apps:lines() do
		utils.search_app(app)
	end
	apps:close()
end

return utils

local ascreen =  require('awful.screen')
local M  = {}

function M.is_displayable(c)
	return not (c.minimized or c.skip_taskbar or c.hidden)
end

function M.get_clients(filter)
	local tag = ascreen.focused().selected_tag
	local clients = tag:clients()

	if type(filter) == 'function' then
		local filtered_clis = {}

		table.for_each(clients, function(cli, i)
			if filter(cli, i) then
				table.insert(filtered_clis, cli)
			end
		end)

		clients = filtered_clis
	end

	return clients
end

return M

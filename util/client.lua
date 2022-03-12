local ascreen =  require('awful.screen')
local client  = {}

function client.displayable_clients(c)
	return not (c.minimized or c.skip_taskbar or c.hidden)
end

function client.get_clients(filter)
	local tag = ascreen.focused().selected_tag
	local clis = tag:clients()

	if type(filter) == 'function' then
		local filtered_clis = {}

		for i, cli in pairs(clis) do
			if filter(cli, i) then
				table.insert(filtered_clis, cli)
			end
		end

		clis = filtered_clis
	end

	return clis
end

return client

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

local minimized_clients = {}
local function minimize_tag_clients(tag, bool)
    for _, cli in pairs(minimized_clients[tag] or {}) do
        cli.minimized = bool
    end
end

function M.minimize_all()
	local current_screen = ascreen.focused()
    assert(current_screen, 'No screen is present currently')

	local current_tags = current_screen.selected_tags

    for _, current_tag in pairs(current_tags) do
        if minimized_clients[current_tag] then
            minimize_tag_clients(current_tag, false)
            minimized_clients[current_tag] = nil
        else
            local clients = current_tag:clients()
            minimized_clients[current_tag] = clients
            minimize_tag_clients(current_tag, true)
        end
    end
end

return M

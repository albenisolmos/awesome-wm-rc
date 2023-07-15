local M = {}

local function place_center(cli, obj)
	obj.x = cli.x + ((cli.width - obj.width) / 2)
	obj.y = cli.y + ((cli.height - obj.height) / 2)
end

function M.popup_show()
	snap_popup.visible = true
end

function M.popup_hide()
	snap_popup.visible = false
end

function M.popup_toggle()
	if snap_popup.visible then
		snap_popup.visible = false
		return
	elseif not client.focus then return end

	grabber_started = true
	keygrabber:start()
	place_center(client.focus, snap_popup)
	snap_popup.visible = true
end

function M.apply(parent_snap)
	local cli = parent_snap or client.focus

	if snapped_clients[cli.id] then
		awesome.emit_signal('switcher::show')
	elseif not cli.snap.parent then
		table.insert(snapped_clients[parent_snap.id], cli)
	end

	--cli.snap.geometry = snap.geometry
end

function M.reset_selection()
    if current_snap_layout then
        current_snap_layout:deselect(last_index)
        current_snap_layout = nil
    end
end


return M

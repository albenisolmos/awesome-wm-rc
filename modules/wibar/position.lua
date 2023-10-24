local MISSING_PIXELS = 3

return function(position, screen, dock)
    if position == 'top' then
        return {
            hide_coord = screen.geometry.y - dock.height,
            show_coord = screen.geometry.y,
            hide_struct = {top = 0},
            show_struct = {top = dock.height},
            overstep_edge = mouse.coords().y >= (screen.geometry.y + MISSING_PIXELS),
        }
    elseif position == 'bottom' then
        return {
            hide_coord = screen.geometry.height + dock.height,
            show_coord = screen.geometry.height - (dock.height),
            hide_struct = {bottom = 0},
            show_struct = {bottom = dock.height},
            overstep_edge = mouse.coords().y <= (screen.geometry.height - MISSING_PIXELS)
        }
    end
end

local wibox = require('wibox')
local gshape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local flowbox = require('widgets.flowbox')
local box = require('widgets.box')

local utils = require('modules.snap.utils')
local snap = require('modules.snap.snap')
local M = {}

local function shape_rounded_rect(cr, w, h)
	gshape.rounded_rect(cr, w, h, dpi(3))
end

local function append_snap(obj, geo, container)
	container:add_at(obj, function(_, args)
		obj.geometry = geo
		return utils.scale_geometry(geo, args.parent, obj.screen.workarea)
	end)
end

local function snap_on_click(self)
	utils.set_geometry(client.focus, self.geometry)
    snap.popup_hide()
    snap.reset_selection()
end

-- Return a widget that reprecent a snap
local function thumb_snap_new(screen)
	return wibox.widget {
		screen = screen,
		geometry = nil,
		layout = box,
		snap_parent = nil,
		bg = beautiful.bg_chips,
		bg_press = beautiful.bg_highlight,
		on_release = snap_on_click,
	}
end

local function snap_layout_new(snapper, screen)
	local ret = box()
	ret.bg = beautiful.bg_chips
	-- TODO: make geometry of bg proportional of the screen
	ret.forced_height = dpi(60)
	ret.forced_width = dpi(100)
	ret.shape = shape_rounded_rect
	ret.shape_border_color = beautiful.bg_chips
	ret.shape_border_width = dpi(2)
    ret.track_size = true

	function ret:select(index)
		if index and self.shape_border_color == beautiful.bg_highlight then
			self:snap(index)
			return
		end
		self.shape_border_color = beautiful.bg_highlight
	end

	function ret:deselect(index)
		local _snap = self.widget.children[index]
		if not snap then return end
		self.shape_border_color = beautiful.bg_chips
		_snap.bg = beautiful.bg_chips
	end

	function ret:snap(index)
		local _snap = self.widget.children[index]
		if _snap then
			snap_on_click(_snap)
		end
	end

	local manual = wibox.layout.manual()
	manual.forced_height = dpi(60)
	manual.forced_width = dpi(100)
	ret.widget = manual

	local snap_parent = thumb_snap_new(screen)
	snapper:add(snap_parent, screen.workarea, nil, append_snap, manual)

	local max_num_snap = tonumber(snapper.max_num_snap)

	-- NOTE: by any reason, lua throw me a error if I write 'for i=2, max_num_span do' so this is the alternative
	local i = 2
	while i == max_num_snap do
		snapper:add(thumb_snap_new(screen), screen.workarea, snap_parent, append_snap, manual)
		i = i + 1
	end

    ret:emit_signal("widget::redraw_needed")
	return ret
end

function M.box_snap_layouts_new(snappers, screen)
	local snap_layout
	local ret = flowbox()
	ret.set_max_num_col = 4
	ret.spacing = dpi(5)

	for _, snapper in pairs(snappers) do
		snap_layout = snap_layout_new(snapper, screen)
		ret:add(snap_layout)
	end

	return wibox.widget {
        layout = box,
        on_mount = function(self, parent)
            parent.width = self.width
            parent.height = self.height
        end,
        track_size = true,
        margin = dpi(8),
        ret
    }
end

return M

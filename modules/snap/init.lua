local wibox = require('wibox')
local beautiful = require('beautiful')
local akey = require('awful.key')
local gtable = require('gears.table')
local gshape = require('gears.shape')
local akeygrabber = require('awful.keygrabber')
local dpi = beautiful.xresources.apply_dpi
local unpack = unpack or table.unpack

local ui = require('modules.snap.ui')
local snap = require('modules.snap.snap')

local snapped_clients = {}
local last_index
local current_snap_layout = nil
local grabber_started = false
local snap_popup = {}
local keygrabber = {}
local M = {}

-- geo1: real geometry by screen
-- context_minor: the minor geometry (ej. the avaliable space of a widget)
-- context_major: the major geometry (ej. the avaliable space in a screen)
-- Set geometry from snap to focused client
function M.on_keymaps()
	return gtable.join(
	akey({SETTINGS.modkey}, 'z', snap.popup_toggle),
	akey({SETTINGS.modkey}, 'x', snap.apply))
end

function M.on_screen(screen)
	local suit = require('modules.snap.suit')
	local box = ui.box_snap_layouts_new(suit, screen)

	snap_popup = wibox {
		screen = screen,
		visible = false,
		ontop = true,
		bg = beautiful.bg,
		shape = function(cr, w, h)
			gshape.rounded_rect(cr, w, h, SETTINGS.client_rounded_corners)
		end,
		widget = box
	}

	keygrabber = akeygrabber {
		stop_key = SETTINGS.modkey,
		stop_event = 'release',
		stop_callback = function()
			if not grabber_started then return end

			snap.popup_hide()
            snap.reset_selection()

			grabber_started = false
		end,
		keypressed_callback = function(_, _, key)
			if key > '9' then return end

			local index = tonumber(key)
			last_index = index

			if current_snap_layout then
				current_snap_layout:select(index)
			else
				local snap_layout = box.children[index]
				if not snap_layout then return end
				snap_layout:select()
			end
		end,
		keyreleased_callback = function(_, _, key)
			if key > '9' then return end

			local index = last_index

			if current_snap_layout then
				current_snap_layout:snap(index)
				snap.popup_hide()
                snap.reset_selection()
			else
				current_snap_layout = box.children[index]
				if not current_snap_layout then return end
				current_snap_layout:select()
			end
		end
	}

	awesome.connect_signal('snap_popup::toggle', snap.popup_toggle)
	awesome.connect_signal('snap_popup::hide', snap.popup_hide)
	awesome.connect_signal('snap_popup::show', snap.popup_show)
end

return M

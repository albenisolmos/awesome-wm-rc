local placement = require('awful.placement')
local ascreen = require('awful.screen')
local spawn = require('awful.spawn')
local timer = require('gears.timer')
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local animate = require 'utils.animate'
local partial_show
local dock = {}

local function current_clients()
	local t = ascreen.focused().selected_tag
	return t:clients()
end

spawn.single_instance('olmos-dock', {
		placement = placement.bottom + placement.center,
		skip_taskbar = true,
		sticky = true,
		callback = function(cli)
			dock = cli
			local s = cli.screen
			local normal_coord = s.geometry.height - dpi(52)
			local offscreen_coord = s.geometry.height + 1

			local function dock_hide()
				if dock.y == offscreen_coord then return end
				partial_show = false
				dock:struts({ bottom = 0 })
				animate.move.y(dock, offscreen_coord)
			end

			local function need_hide_dock()
				local clients = current_clients()

				if #clients > 0 then
					for _, client in pairs(clients) do
						if (client.maximized or client.fullscreen) and not client.minimized then
							return true
						end
					end
				end

				return false
			end

			local time_hide_dock = timer {
				timeout = 1,
				autostart = false,
				single_shot = true,
				callback = function()
					dock_hide()
				end
			}

			dock:connect_signal('mouse::leave', function()
				if partial_show then
					time_hide_dock:start()
				end
			end)

			dock:connect_signal('mouse::enter', function()
				if time_hide_dock.started then
					time_hide_dock:stop()
				end
			end)

			local function dock_show()
				if dock.y == normal_coord then return end
				partial_show = true
				animate.move.y(dock, normal_coord)
				if _G.preferences.dock_autohide then
					dock.ontop = true
					time_hide_dock:start()
				else
					dock:struts({ bottom = dpi(48) })
				end
			end

			awesome.connect_signal('dock::kill', function ()
				dock:kill()
				dock = nil
			end)

			awesome.connect_signal('dock::update', function()
				if not dock then return end
				if need_hide_dock() then
					dock_hide()
				else
					dock_show()
				end
			end)

			awesome.connect_signal('dock::partial_show', function()
				if dock.y == normal_coord then return end
				dock.ontop = true
				partial_show = true
				animate.move.y(dock, normal_coord)
				time_hide_dock:start()
			end)

			local function client_toggle_dock(c)
				if c.maximized or c.fullscreen then
					dock.ontop = true
					dock_hide()
				else
					if need_hide_dock() then
						return
					else
						dock.ontop = false
						dock_show()
					end
				end
			end

			screen.connect_signal('tag::history::update', function()
			end)

			client.connect_signal('property::maximized', client_toggle_dock)
			client.connect_signal('property::fullscreen', client_toggle_dock)
			tag.connect_signal('property::layout', function(t)
				local clients = t:clients()
				for _, c in pairs(clients) do
					if not c.floating then
						dock.ontop = true
						dock_hide()
						return
					end
				end
			end)

		end}
		)

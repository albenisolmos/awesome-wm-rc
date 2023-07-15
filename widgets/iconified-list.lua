local button     = require('awful.button')
local shape     = require('gears.shape')
local gsurface  = require('gears.surface')
local filesystem = require('gears.filesystem')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

local multispawn = require 'util.multispawn'
local apps      = require 'apps'
local cache_path = filesystem.get_configuration_dir() .. '/cache'

local iconifieds
local iconified_list = wibox.layout.fixed.horizontal()

local function save_preview(c)
	gsurface(c.content):write_to_png(cache_path)
end

function iconified_list:update()
	local t = awful.screen.focused().selected_tag
	local clients = t:clients()

	for i, client in pairs(clients) do
		iconifieds[i] = client
	end
end

function iconified_list:new_iconified(c)
	return wibox.widget {
		layout = wibox.layout.stack,
		{
			widget = wibox.widget.imagebox,
			image = get_preview(c)
		},
		{
			layout = wibox.container.place,
			valign = 'top',
			halign = 'left',
			{
				widget = wibox.widget.imagebox,
				image = c.icon
			}
		}
	}
end

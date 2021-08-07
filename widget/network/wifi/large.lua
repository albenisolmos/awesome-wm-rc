local wibox     = require('wibox')
local abutton   = require('awful.button')
local beautiful = require('beautiful')
local shape     = require('gears.shape')
local spawn     = require('awful.spawn')
local dpi       = beautiful.xresources.apply_dpi
local clickable = require('widget.clickable')
local switch    = require('widget.switch')
local app       = require 'apps'

local networks_data = {}
local wifi_list = wibox.layout.fixed.vertical()

local widget_message = wibox.widget {
	layout        = wibox.container.background,
	fg            = beautiful.fg_soft_medium,
	forced_height = dpi(30),
	wibox.widget.textbox('No avaliable networks')
}

local function build_wifi_widget(essid)
	local bg = beautiful.bg_chips

	if essid == _G.essid then
		bg = beautiful.bg_highlight
	end

	return wibox.widget {
		layout    = clickable,
		bg_normal = beautiful.transparent,
		bg_hover  = beautiful.bg_hover,
		bg_press  = beautiful.bg_press,
		shape     = shape.rounded_rect,
		{
			layout = wibox.container.margin,
			margins = dpi(5),
			{
				layout        = wibox.layout.fixed.horizontal,
				spacing       = dpi(10),
				forced_height = dpi(20),
				{
					layout = wibox.container.background,
					bg     = bg,
					shape  = shape.circle,
					{
						layout  = wibox.container.margin,
						margins = dpi(3),
						{
							widget = wibox.widget.imagebox,
							image  = beautiful.icon_wifi_on
						}
					}
				},
				{
					widget = wibox.widget.textbox,
					text   = essid,
					font   = beautiful.font,
				},
				nil
			}
		}
	}
end

local function update_data_networks()
	spawn.easy_async_with_shell('iwlist wlp3s0 scan', function(stdout)
		local i = 1
		for essid in stdout:gmatch('ESSID:(.-)\n') do
			essid = essid:match('"(.-)"')
			networks_data[i] = { essid }
			i = i + 1
		end
		i = 1
		for quality in stdout:gmatch('Quality=(.-)%s') do
			networks_data[i][2] = quality
			i = i + 1
		end
	end)
end

function wifi_list:update()
	self:reset()

	update_data_networks()
	for i, network in pairs(networks_data) do
		self:add(build_wifi_widget(network[1]))
	end

	if #self.children == 0 then
		self:reset()
		self:add(widget_message)
	end
end

local large = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(5),
	{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		forced_height = dpi(20),
		{
			widget = wibox.widget.textbox,
			text = 'Wi-fi',
			font = beautiful.font_bold,
		},
		nil,
		{
			widget = switch,
			state = true,
			align = 'right',
			callback_active = function()
				awesome.emit_signal('wifi::status', true)
			end,
			callback_disable = function()
				awesome.emit_signal('wifi::status', false)
			end,
			id = 'id_switch'
		}
	},
	{
		widget        = wibox.widget.separator,
		forced_height = dpi(1)
	},
	wifi_list,
	{
		widget        = wibox.widget.separator,
		color         = beautiful.bg_medium,
		forced_height = dpi(1)
	},
	{
		widget = wibox.widget.textbox,
		text = 'Wifi Preferences',
		font = beautiful.font,
		valign = 'center',
		forced_height = dpi(35),
		buttons = {
			abutton({}, 1, nil, function() spawn('wicd-gtk') end)
		}
	}
}

large:connect_signal('mouse::enter', function()
	wifi_list:update()
end)

awesome.connect_signal('wifi::status', function(status)
	if status then
		large:get_children_by_id('id_switch')[1]:set_state_weak(true)
	else
		large:get_children_by_id('id_switch')[1]:set_state_weak(false)
	end
end)

wifi_list:update()

return large

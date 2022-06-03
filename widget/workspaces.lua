local awidget = require('awful.widget')
local spawn = require('awful.spawn')
local abutton = require('awful.button')
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi
local shape     = require("gears.shape")
local gtable = require('gears.table')
local uclient = require('utils.client')

local popup = {}

local workspacesWidget = wibox.widget {
	widget = wibox.widget.textbox,
	text = 'Workspaces',
	font = beautiful.font_bold,
	valign = 'center'
}

local layoutlist = awidget.layoutlist {
	base_layout = wibox.widget {
		layout          = wibox.layout.grid.vertical,
		spacing         = 10,
		forced_num_cols = 8
	},
	widget_template = {
		widget          = wibox.container.background,
		shape           = shape.rounded_rect,
		forced_width    = 32,
		forced_height   = 32,
		id              = 'background_role',
		{
			widget  = wibox.container.margin,
			margins = 4,
			{
				widget        = wibox.widget.imagebox,
				forced_height = dpi(22),
				forced_width  = dpi(22),
				id            = 'icon_role'
			}
		}
	}
}

local createClientUI = function(client, tag)
	local widget = wibox.widget {
		layout = wibox.container.background,
		shape = shape.rounded_rect,
		{
			widget = wibox.container.margin, 
			margins = dpi(8), 
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(10), 
				{
					layout = wibox.layout.align.vertical,
					expand = "none", 
					nil, 
					{
						widget = wibox.widget.imagebox,
						image = client.icon,
						forced_height = dpi(20), 
						forced_width = dpi(20),  
					}, 
					nil
				}, 
				{
					widget = wibox.widget.textbox,
					markup = client.name, 
					font = beautiful.font_medium,
					valign = "center",
					forced_height = dpi(20)
				}
			}
		}
	}

	widget:buttons(gtable.join(
			abutton({ }, 1, function()
				client:raise()
				tag:view_only()
				popup.visible = false
			end)
	))

	widget:connect_signal("mouse::enter", function()
		widget.bg = beautiful.bg_chips
	end)
	widget:connect_signal("mouse::leave", function()
		widget.bg = beautiful.transparent
	end)

	return widget
end

local createTagUI = function(tag, clients)
	local clientsContainer = wibox.layout.fixed.vertical()
	clientsContainer.spacing = 5

	for _, c in pairs(clients) do
		clientsContainer:add(createClientUI(c, tag))
	end

	return wibox.widget {
		{
			font = "Roboto Regular 10", 
			markup = "<span foreground='#cccccc8a'>Workspace "..tostring(tag.name).."</span>", 
			widget = wibox.widget.textbox
		}, 
		{
			widget = wibox.widget.separator,
			color  = '#b8d2f82a',
			forced_height = 1,
		},
		clientsContainer, 
		spacing = 5, 
		layout = wibox.layout.fixed.vertical
	}
end

local createSettingsUI = function() 
	local newWorkspace = wibox.widget.textbox('New workspace')
	newWorkspace:connect_signal("button::press", function() 
		for _, tag in pairs(root.tags()) do
			if #tag:clients() == 0 then
				tag:view_only()
				popup.visible = false
				break 
			end
		end
	end)

	local taskManager = wibox.widget.textbox('Task manager...')
	taskManager:connect_signal("button::press", function() 
		spawn("lxtask")
		popup.visible = false
	end)

	return wibox.widget {
		newWorkspace,
		taskManager,
		spacing = 7,
		layout = wibox.layout.fixed.vertical
	}
end

local workspacesLayout = wibox.layout.fixed.vertical()
workspacesLayout.spacing = 7

local updateWidget = function()
	workspacesLayout:reset(workspacesLayout)
	for _, tag in pairs(root.tags()) do
		local clients = tag:clients()
		clients = table.filter(clients, uclient.is_displayable)

		if #clients > 0 then
			workspacesLayout:add(createTagUI(tag, clients))
		end
	end
end

local popupWidget = wibox.widget {
	layout = wibox.layout.fixed.vertical, 
	spacing = 10, 
	{
		layout = wibox.layout.align.horizontal,
		expand = "none", 
		nil,
		layoutlist,
		nil
	},
	workspacesLayout,
	{
		widget = wibox.widget.separator,
		color  = '#b8d2f82a',
		forced_height = 1,
	},
	createSettingsUI()
}

workspacesWidget:connect_signal("button::press", function() 
	updateWidget()
	awesome.emit_signal('popup::open', popupWidget)
end)

return workspacesWidget

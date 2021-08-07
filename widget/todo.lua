local awful               = require('awful')
local wibox               = require('wibox')
local shape               = require('gears.shape')
local beautiful           = require('beautiful')
local dpi                 = beautiful.xresources.apply_dpi
local clickable           = require 'widget.clickable'

local tasks_cache = os.getenv('HOME') .. '/.config/awesome/cache/todo'
local atextbox  = wibox.widget.textbox()
local tasks_table = {}

local function build_task(name, widget)
	local buttonsTask = wibox.widget
	{
		layout = wibox.container.background,
		bg = beautiful.bg_chips,
		shape = shape.rounded_rect,
		forced_height = dpi(30),
		forced_width = dpi(80),
		{
			layout = wibox.layout.align.horizontal,
			{
				layout = wibox.container.background,
				bg = beautiful.transparent,
				id = 'id_bg_done',
				{
					layout = wibox.container.margin,
					margins = dpi(10),
					{
						image = beautiful.icon_done,
						widget = wibox.widget.imagebox
					}
				}
			},
			{
				image = beautiful.icon_separator,
				widget = wibox.widget.imagebox
			},
			{
				id = 'id_bg_delete',
				bg = '#00000000',
				layout = wibox.container.background,
				{
					margins = dpi(10),
					layout = wibox.container.margin,
					{
						image = beautiful.icon_close,
						widget = wibox.widget.imagebox
					}
				}
			}
		}
	}
	buttonsTask.visible = false

	local buttonDone = buttonsTask:get_children_by_id('id_bg_done')[1]
	local buttonDelete = buttonsTask:get_children_by_id('id_bg_delete')[1]

	buttonDone:set_shape(function(cr, width, height)
		shape.partially_rounded_rect(cr, width, height, true, false, false, true, dpi(10))
	end)
	buttonDelete:set_shape(function(cr, width, height)
		shape.partially_rounded_rect(cr, width, height, false, true, true, false, dpi(10))
	end)

	buttonDone:connect_signal('mouse::enter', function(self)
		self:set_bg('#3ca734' .. '90')
	end)

	buttonDone:connect_signal('mouse::leave', function(self)
		self:set_bg('#00000000')
	end)

	buttonDelete:connect_signal('mouse::enter', function(self)
		self:set_bg('#c22727' .. '90')
	end)

	buttonDelete:connect_signal('mouse::leave', function(self)
		self:set_bg('#00000000')
	end)

	local task = wibox.widget
	{
		layout = wibox.layout.flex.horizontal,
		forced_height = dpi(40),
		id = 'id_task',
		{
			layout = wibox.layout.align.horizontal,
			expand = 'inside',
			{
				bg     = beautiful.bg_chips,
				shape  = shape.rounded_rect,
				layout = wibox.container.background,
				{
					margins = dpi(10),
					layout  = wibox.container.margin,
					{
						markup = name,
						align  = 'left',
						valign = 'center',
						widget = wibox.widget.textbox
					}
				}
			},
			nil,
			buttonsTask
		}
	}

	buttonDone:connect_signal('button::release', function()
		local index = widget:get_children_by_id('task_list')[1]:index(task)
		widget:get_children_by_id('task_list')[1]:remove(index)
	end)

	buttonDelete:connect_signal('button::release', function()
		local index = widget:get_children_by_id('task_list')[1]:index(task)
		widget:get_children_by_id('task_list')[1]:remove(index)
		delete_task(index)
	end)

	task:get_children_by_id('id_task')[1]:connect_signal(
	'mouse::enter', function()
		buttonsTask.visible = true
	end)

	task:get_children_by_id('id_task')[1]:connect_signal(
	'mouse::leave', function()
		buttonsTask.visible = false
	end)

	return task
end

local toDo = wibox.widget
{
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(10),
	{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			markup = '<span font="Ubuntu 14">To Do</span>',
			widget = wibox.widget.textbox
		},
		atextbox,
		{
			widget = clickable,
			bg = '#00000000',
			shape = shape.rounded_bar,
			id = 'button',
			{
				margins = dpi(10),
				layout = wibox.container.margin,
				{
					image        = beautiful.icon_plus,
					resize       = true,
					forced_height= dpi(15),
					forced_width = dpi(15),
					widget       = wibox.widget.imagebox
				}
			}
		}
	},
	{
		id = 'task_list',
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(10),
	}
}

local function remember_task()
	tasks = io.open(tasks_cache, 'r')
	for task in tasks:lines() do
		toDo:get_children_by_id('task_list')[1]:add(build_task(task, toDo))
		table.insert(tasks_table, task)
	end
	tasks:close()
end

remember_task()

function save_tasks()
	-- Clear cache
	local cache = io.open( tasks_cache, 'w' )
	cache:write()
	cache:close()

	-- Write new cache
	cache = io.open( tasks_cache, 'a' )
	for _, task in ipairs(tasks_table) do    
		cache:write(task, '\n')
	end
	cache:close()
end

function delete_task(index)
	table.remove(tasks_table, index)
	save_tasks(tasks_table)
end

function write_task(task)
	toDo:get_children_by_id('task_list')[1]:add(build_task( task, toDo ))
	table.insert(tasks_table, task)
	save_tasks()
end

toDo:get_children_by_id('button')[1]:connect_signal(
'button::release', function()
	awful.prompt.run {
		prompt       = '',
		bg_cursor    = '#D8D8D8',
		textbox      = atextbox,
		exe_callback = function(input)
			write_task(input)
		end
	}  
end)

return toDo

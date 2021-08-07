local awful     = require('awful')

local wibox     = require('wibox')
local spawn     = require('awful.spawn')
local button    = require('awful.button')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local utils     = require('menubar.utils')
local dpi       = beautiful.xresources.apply_dpi
local naughty   = require('naughty')

local home      = os.getenv('HOME')
local size_icon = '48x48'
local apps_path = '/usr/share/applications'
local icon_path = '/usr/share/icons/Papirus/' .. size_icon .. '/mimetypes'
local icon_places_path = '/usr/share/icons/Papirus/' .. size_icon .. '/places'

local grid = wibox.widget {
	layout     = wibox.layout.grid,
	orientation= 'horizontal',
	homogenous = false,
	expand     = false,
	forced_num_rows = 10,
	forced_num_cols = 20,
}

local item_menu = awful.menu({
	items = {
		{ 'Open', function() return end },
		{ 'Rename' , function() return end },
		{ 'Move to trash', function() return end },
	}
}) 

local function get_output(command)
	--[[	local output

	awful.spawn.easy_async_with_shell(command, function(stdout)
	output = stdout
	end)

	return output]]
	local output
	command = io.popen(command)
	output = command:read('*all')
	command:close()

	return output
end

local function get_filetype(filename)
	return get_output('xdg-mime query filetype ' .. filename)
end

local function find_icon(filename)
	local results, mimetype

	mimetype = get_output('xdg-mime query filetype ' .. filename):gsub('/', '-'):gsub('%\n', '')

	if mimetype == 'inode-directory' then
		results = get_output(string.format('find %s -name "*folder-blue.svg*"', icon_places_path))
	else
		results = get_output(string.format('find %s -name "*%s*"', icon_path, mimetype))
	end

	for posible_icon in results:gmatch('[^\r\n]+') do
		return posible_icon
	end
end

local function build_item(args, screen)
	local icon = wibox.widget.imagebox(args.icon)
	icon.forced_height = 42
	icon.forced_width = 42

	if #args.label > 14 then
		args.label = args.label:sub(1, 14) .. '\n' .. args.label:sub(15, -1)
	end

	local label = wibox.widget.textbox(args.label)
	label:set_align('center')

	local width, height = label:get_preferred_size(screen)

	local layout = wibox.widget {
		widget = wibox.layout.fixed.vertical,
		forced_height = 45 + height,
		spacing = dpi(5),
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			nil,
			icon,
			nil
		},
		label
	}

	local margin = wibox.container.margin(layout, dpi(5), dpi(5), dpi(5), dpi(5))
	local background = wibox.container.background(margin, '#0000000', shape.rounded_rect)
	background:set_fg('#FFFFFF70')

	background:connect_signal('mouse::enter', function(self)
		self:set_bg('#00000010')
	end)
	background:connect_signal('mouse::leave', function(self)
		self:set_bg(beautiful.transparent)
	end)

	background:buttons({
		button({ }, 1, function()
			background:set_bg('#00000018')
			spawn(args.onclick)
		end, function() background:set_bg(beautiful.transparent) end),
		button({ }, 3, function()
			item_menu:delete(1)
			item_menu:add( {'Open', function() spawn(args.onclick) end}, 1)
			item_menu:delete(3)
			item_menu:add( {'Move to trash', function()
				grid:remove(background)
				spawn.with_shell(string.format('mv %s %s/.local/share/Trash/files/',
				args.path, home))
			end }, 3)
			item_menu:toggle()
		end)
	})

	return background
end

local function spawn_filetype(filename)
	local spawn, mimetype
	local find_app_mimetype, app_mimetype
	local find_app_file, app_file
	local mimetype = get_filetype(filename)

	if mimetype:find('text') then
		return string.format('terminator --layout=large -e "vim %s"', filename)
	end

	-- get default application for open current filetype
	app_file = get_output('xdg-mime query default ' .. mimetype):gsub('%\n', '')

	if not app_file or app_file == '' then
		return
	end

	-- find desktop file of curret app
	possible_apps = get_output(string.format('find %s -maxdepth 1 -name "*%s*"', apps_path, app_file))
	if not possible_apps then return end

	for posible_app in possible_apps:gmatch('[^\r\n]+') do
		app = posible_app
		break
	end

	if app == '/usr/share/applications/' or not app or app == '' then
		return
	end

	local app_file = io.open(app, 'r')
	local app_file_content = app_file:read('*all')
	app_file:close()

	spawn = app_file_content:match('Exec=(.-)\n'):gsub('(%%..-)', '')

	return string.format('%s %s', spawn, filename)
end

local function get_elements()
	local elements = {}
	local content = get_output('find ' .. home .. '/Desktop -maxdepth 1')

	for element in content:gmatch('[^\r\n]+') do
		if element == home .. '/Desktop' then
			goto continue
		end

		table.insert(elements, {
			icon = find_icon(element),
			label = element:match('^.+/(.+)$'),
			onclick = spawn_filetype(element),
			path = element
		})

		::continue::
	end

	return elements
end

return function(screen)
	local function update_desktop()
		grid:reset()
		for _, item in pairs(get_elements()) do
			grid:add(build_item(item, screen))
		end
	end

	if beautiful.desktop_icon then
		update_desktop()
	end

	awesome.connect_signal('desktop::update', update_desktop)

	return wibox {
		screen  = screen,
		type    = 'desktop',
		bg      = beautiful.transparent,
		width   = screen.geometry.width,
		height  = screen.geometry.height,
		ontop   = false,
		visible = true,
		widget  = {
			layout = wibox.container.margin,
			top = dpi(35),
			left = dpi(10),
			right = dpi(10),
			bottom = dpi(10),
			buttons = {
				button({}, 1, function()
					awesome.emit_signal('popup::hide')
					item_menu:hide()
				end)
			},
			grid
		}
	}
end

local menu = require('awful.menu')

return function(props)
	local _menu = menu(props)
	awesome.connect_signal('menu::hide', function()
		_menu:hide()
	end)
	return _menu
end

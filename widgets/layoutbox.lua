local awidget = require('awful.widget')
local alayout = require('awful.layout')
local abutton = require('awful.button')
local applet = require 'widget.applet'

return function(screen)
	local layoutbox = applet(awidget.layoutbox(screen))

	layoutbox:buttons({
		abutton({ }, 1, function() alayout.inc( 1) end),
		abutton({ }, 3, function() alayout.inc(-1) end),
		abutton({ }, 4, function() alayout.inc( 1) end),
		abutton({ }, 5, function() alayout.inc(-1) end)
	})

	return layoutbox
end

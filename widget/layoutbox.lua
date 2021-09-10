local awful  = require('awful')
local applet = require 'widget.applet'

return function(screen)
	local layoutbox = applet(awful.widget.layoutbox(screen))

	layoutbox:buttons({
		awful.button({ }, 1, function() awful.layout.inc( 1) end),
		awful.button({ }, 3, function() awful.layout.inc(-1) end),
		awful.button({ }, 4, function() awful.layout.inc( 1) end),
		awful.button({ }, 5, function() awful.layout.inc(-1) end)
	})

	return layoutbox
end

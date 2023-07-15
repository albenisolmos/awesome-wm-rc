local udock = require('modules.dock.utils')
local M = {}

function M.init()
	awesome.connect_signal('dock::show_temporarily', udock.show_temporarily)
	awesome.connect_signal('dock::show', udock.show)
	awesome.connect_signal('dock::hide', udock.hide)
	udock.hide()
end

function M.finish()
	awesome.disconnect_signal('dock::show_temporarily', udock.show_temporarily)
	awesome.disconnect_signal('dock::show', udock.show)
	awesome.disconnect_signal('dock::hide', udock.hide)
	udock.hide()
end

return M

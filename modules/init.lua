local module = require('module')
local settings = require('settings')

module.load('modules.client')
module.load('modules.wallpaper')
module.load('modules.popup')
module.load('modules.wibar')
module.load('modules.switcher')
--module.load('modules.snap')
module.load('modules.color-picker')
module.load('modules.dock')
if settings.test then
    module.load('modules.test')
end

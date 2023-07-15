local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local settings
local M = {}

function M.init()
    local settings_path = gfilesystem.get_xdg_config_home()..'awesomerc.lua'
    settings = gfilesystem.file_readable(settings_path)
        and dofile(settings_path)
        or require('settings-default')

    M = gtable.join(settings, M)

    return M
end

setmetatable(M, {__index = function(t, k)
    return rawget(t, k) or settings[k]
end})

return M

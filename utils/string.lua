string.concat = string.concat and string.concat or function(...)
    local str = ''
    for _, val in pairs({...}) do
        str = str..val
    end
    return str
end

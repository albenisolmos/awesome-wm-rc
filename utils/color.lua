local M = {}

-- convert a decimal value to hex
local function d2h(d)
    return string.format('%X', d)
end

-- convert a hex value to decimal 
local function h2d(h)
    return tonumber(h, 16)
end

local function substr(str, start, length)
    start = start == 0  and 1 or start
    return string.sub(str, start, start + length - 1)
end

-- remove the '#' character from the begin
local function clear_color(color)
    if string.sub(color,1,1) == '#' then
        color = string.sub(color,2)
    end

    return color
end

function M.blend_hexcolor(color1, color2, weight)
    color1 = clear_color(color1)
    color2 = clear_color(color2)
    -- set the weight to 50%, if that argument is omitted
    weight = (type(weight) == 'number') and weight or 50
    -- Convert hex color strings to RGB values
    local r1, g1, b1 = tonumber(color1:sub(1, 2), 16), tonumber(color1:sub(3, 4), 16), tonumber(color1:sub(5, 6), 16)
    local r2, g2, b2 = tonumber(color2:sub(1, 2), 16), tonumber(color2:sub(3, 4), 16), tonumber(color2:sub(5, 6), 16)

    -- Calculate blended RGB values using weighted average
    local r = math.floor((1 - weight) * r1 + weight * r2 + 0.5)
    local g = math.floor((1 - weight) * g1 + weight * g2 + 0.5)
    local b = math.floor((1 - weight) * b1 + weight * b2 + 0.5)

    -- Convert blended RGB value to hex color string
    local hex = string.format("#%02X%02X%02X", r, g, b)

    return hex
end
--Hex blending algorithm
function M.mix(color_1, color_2, weight)
    weight = (type(weight) ~= 'number') and weight or 50 -- set the weight to 50%, if that argument is omitted

    color_1 = clear_color(color_1)
    color_2 = clear_color(color_2)

    local color = "#";

    for i=0, 4, 2 do -- loop through each of the 3 hex pairs—red, green, and blue
        local v1 = h2d(substr(color_1, i, 2)) -- extract the current pairs
        local v2 = h2d(substr(color_2, i, 2))

        -- combine the current pairs from each source color, according to the specified weight
        local val = d2h(math.floor(v2 + (v1 - v2) * (weight / 100.0)))

        while #val < 2 do
            val = '0' + val -- prepend a '0' if val results in a single digit
        end

        color = color .. val -- concatenate val to our new color string
    end

    return color
end

return M

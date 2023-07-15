local wcontainer = require('wibox.container')
local FIELDS = {'margin', 'bg', 'padding'}
local widget = { mt = {} }

local function get_widget_by_field(w, field, i)
    i = i or  1

    if not w then
        return false
    elseif FIELDS[field] == i then
        return w.field == field and w or false
    end

    local wd = get_widget_by_field(w.widget, field, i+1)
    return wd == false and w or wd
end

local function set_props(w, props, on_failure)
    if type(props) ~= 'table' then
        pcall(on_failure, w, props)
        return
    end

    for k, v in pairs(props) do
        if w[k] then
            w[k] = v
        end
    end
end

local handler = {
    padding = function(w, v)
        local function on_failure(wd, val)
            if type(val) == 'number' then
                wd.margins = val
            end
        end

        local wd = get_widget_by_field(w, 'padding')

        if  wd.field ~= 'padding' then
            local margin = wcontainer.margin()
            margin.widget = w.widget
            margin.filed = 'padding'
            w.widget = nil
            w.widget = margin;
        end

        set_props(wd, v, on_failure)
    end,
    margin = function(w, v)
        if type(v) == 'table' then
            set_props(w,v)
        else
            w.margins = v
        end
    end,
    bg = function(w, v)
        local function on_failure(wd, val)
            if type(val) == 'string' then
                wd.bg = val
            end
        end

        local wd = get_widget_by_field(w, 'bg')

        if  wd.field ~= 'bg' then
            local bg = wcontainer.background()
            bg.widget = w.widget
            w.widget = nil
            w.widget = bg
            set_props(bg, v, on_failure)
        end

        set_props(wd, v)
    end
}

local base = require('wibox.widget.base')
local gtable = require('gears.table')

function widget.new(...)
    local w = wcontainer.margin()
    w.field = 'margin'

    for v, arg in pairs(...) do
        if type(arg) == 'table' then
            --base.check_widget(arg)
            local wd = get_widget_by_field(w, 'padding')
            wd.widget = arg
        elseif handler[v] then
            handler[v](w, arg)
        end
    end
    return w
end

function widget.mt:__call(...)
    return widget.new(...)
end

return setmetatable(widget, widget.mt)

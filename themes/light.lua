--================================================
--              My Awesome Theme                ==
--================================================

local shape = require('gears.shape')
local dir   = require('gears.filesystem').get_configuration_dir() .. '/themes/'
local dpi   = require('beautiful').xresources.apply_dpi

local layout_icons   = dir .. 'dark_icons/layouts/'
local titlebar_icons = dir .. 'dark_icons/titlebar/'
local default_font   = 'SF Pro Display '
local theme          = {}

-- Variables
theme.font        = default_font .. ' 10'
theme.font_medium = default_font .. 'Regular 12'
theme.font_small  = default_font .. 'Regular 10' 
theme.font_bold   = default_font .. 'Semi-Bold 10'

theme.wallpaper = dir .. 'wallpaper.jpg'
theme.icon_user = dir .. 'icon-user.png'

-- Separation among clients
theme.useless_gap      = dpi(10)
theme.switcher_preview = false
theme.dock_use         = false
theme.dock             = false
theme.dock_autohide    = false
theme.desktop_icon     = false

theme.bg        = '#FFFFFF'
theme.bg_card   = '#f2f2f2'
theme.bg_chips  = '#D5D5D5'
theme.bg_hover  = '#242424'
theme.bg_press  = '#292929'
theme.bg_urgent = '#ff0000'

theme.bg_highlight = '#228ae7d8'
theme.transparent  = '#00000000'

theme.border_width  = dpi(1)
theme.border_normal = '#292929'
theme.border_focus  = '#252525'
theme.border_marked = '#91231c'

theme.fg_normal   = '#1A1A1A'
theme.fg_focus    = '#1A1A1a'
theme.fg_urgent   = '#ffffff'
theme.fg_minimize = '#ffffff'
theme.fg_soft     = '#1A1A1A70'
theme.fg_soft_medium = '#1A1A1AD0'
theme.fg_soft_focus = '#1A1A1AD0'

-- Taglist
theme.taglist_bg_empty           = '#00000000'
theme.taglist_bg_occupied        = '#00000000'
theme.taglist_fg_occupied        = '#81A2BE'
theme.taglist_bg_urgent          = '#CC6666'
theme.taglist_bg_focus           = '#00000000'
theme.taglist_shape_border_color = '#22242E'

-- Menu
theme.menu_height       = dpi(25)
theme.menu_width        = dpi(150)
theme.menu_bg_normal    = theme.bg
theme.menu_bg_focus     = '#228AE7'
theme.menu_border_width = 0
theme.menu_border_color = '#0c1E26'
theme.menu_shape        = shape.rounded_rect

--  Tasklist
theme.tasklist_font            = 'ubuntu medium 10'
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon    = false
theme.tasklist_align           = 'left'
theme.tasklist_spacing         = dpi(5)
theme.tasklist_fg_normal       = '#737373'
theme.tasklist_bg_normal       = theme.transparent
theme.tasklist_fg_focus        = '#D8D8D8'
theme.tasklist_bg_focus        = theme.bg_chips
theme.tasklist_bg_urgent       = '#22242e20'
theme.tasklist_fg_minimize     = '#737373'
theme.tasklist_bg_minimize     = theme.bg_trans
theme.tasklist_shape           = shape.rounded_rect
theme.tasklist_shape_focus     = shape.rounded_rect

-- Switch
theme.switch_bar_color        = theme.bg_chips
theme.switch_bar_color_active = theme.bg_highlight
theme.switch_bar_height       = dpi(20)
theme.switch_bar_width        = dpi(35)
theme.switch_bar_shape        = shape.rounded_bar
theme.switch_bar_border_color = theme.bg_highlight
theme.switch_bar_border_width = 1

theme.switch_handle_color = "#FFFFFF"
theme.switch_handle_height = dpi(15)
theme.switch_handle_width = dpi(15)
theme.switch_handle_shape = shape.circle
theme.switch_handle_border_width = 0
theme.switch_handle_border_color = theme.bg_highlight

-- Tooltip
theme.tooltip_bg           = theme.bg
theme.tooltip_fg           = '#D8D8D8'
theme.tooltip_border_color = '#00000050'
theme.tooltip_border_width = dpi(1)
theme.tooltip_shape        = shape.rounded_rect
theme.tooltip_gaps         = dpi(5)

-- Hotkeys
theme.hotkeys_bg           = theme.bg_trans
--theme.hotkeys_font         = theme.font
theme.hotkeys_shape        = shape.rounded_rect
--theme.hotkeys_modifiers_fg = theme.font_bold
theme.hotkeys_border_width = dpi(2)
theme.hotkeys_border_color = '#00000015'
--theme.hotkeys_group_margin = dpi(10)

-- Progressbar
theme.progressbar_bg    = theme.bg_chips
theme.progressbar_fg    = '#ffffff'
theme.progressbar_shape = shape.rounded_bar

-- Naughty
theme.notification_font     = theme.font
theme.notification_fg       = theme.fg_normal
theme.notification_bg       = theme.bg
theme.notification_shape    = shape.rounded_rect
theme.notification_critical = '#b52b2b'

-- Slider
theme.slider_bar_color           = theme.bg_chips
theme.slider_bar_shape           = shape.rounded_bar
theme.slider_bar_height          = dpi(18)
theme.slider_bar_active_color    = '#ffffff'
theme.slider_bar_border_width    = dpi(1)
theme.slider_handle_color        = '#ffffff'
theme.slider_handle_shape        = shape.circle
theme.slider_handle_width        = dpi(19)
theme.slider_handle_border_color = '#999999'
theme.slider_handle_border_width = dpi(1)

-- Prompt
theme.prompt_bg_cursor = '#FFFFFF'
theme.prompt_bg        = theme.transparent
theme.prompt_fg_cursor = '#FFFFFF'
theme.prompt_font      = 'Ubuntu 15'

-- Systray
theme.bg_systray           = theme.transparent
theme.systray_icon_spacing = dpi(10)

theme.separator_color = theme.bg_chips
theme.separator_shape = shape.rounded_bar

--  Titlebar
theme.titlebar_bg = theme.bg
theme.titlebar_fg = '#606060'

-- Snap
theme.snap_bg = theme.bg_hi
theme.snap_border_width = dpi(2)

-- Define the images to load
theme.titlebar_close_button_normal      = titlebar_icons .. 'inactive.png'
theme.titlebar_close_button_focus       = titlebar_icons .. 'close_focus.png'
theme.titlebar_close_button_focus_hover = titlebar_icons .. 'close_focus_hover.png'
theme.titlebar_close_button_focus_press = titlebar_icons .. 'close_focus_press.png'

theme.titlebar_minimize_button_normal      = titlebar_icons .. 'inactive.png'
theme.titlebar_minimize_button_focus       = titlebar_icons .. 'minimize_focus.png'
theme.titlebar_minimize_button_focus_hover = titlebar_icons .. 'minimize_focus_hover.png'
theme.titlebar_minimize_button_focus_press = titlebar_icons .. 'minimize_focus_press.png'

theme.titlebar_maximized_button_focus_active         = titlebar_icons .. 'inactive.png'
theme.titlebar_maximized_button_focus_active_hover   = titlebar_icons .. 'maximize_inactive_hover.png'
theme.titlebar_maximized_button_normal_inactive      = titlebar_icons .. 'inactive.png'
theme.titlebar_maximized_button_focus_inactive       = titlebar_icons .. 'maximize_focus.png'
theme.titlebar_maximized_button_focus_inactive_hover = titlebar_icons .. 'maximize_focus_hover.png'
theme.titlebar_maximized_button_focus_inactive_press = titlebar_icons .. 'maximize_focus_press.png'

-- Icon Layouts
theme.layout_fairh      = layout_icons .. 'fairhw.png'
theme.layout_fairv      = layout_icons .. 'fairvw.png'
theme.layout_floating   = layout_icons .. 'floatingw.png'
theme.layout_magnifier  = layout_icons .. 'magnifierw.png'
theme.layout_max        = layout_icons .. 'maxw.png'
theme.layout_fullscreen = layout_icons .. 'fullscreenw.png'
theme.layout_tilebottom = layout_icons .. 'tilebottomw.png'
theme.layout_tileleft   = layout_icons .. 'tileleftw.png'
theme.layout_tile       = layout_icons .. 'tilew.png'
theme.layout_tiletop    = layout_icons .. 'tiletopw.png'
theme.layout_spiral     = layout_icons .. 'spiralw.png'
theme.layout_dwindle    = layout_icons .. 'dwindlew.png'
theme.layout_cornernw   = layout_icons .. 'cornernww.png'
theme.layout_cornerne   = layout_icons .. 'cornernew.png'
theme.layout_cornersw   = layout_icons .. 'cornersww.png'
theme.layout_cornerse   = layout_icons .. 'cornersew.png'

local icon_dir = dir .. 'dark_icons/'
theme.icon_launcher       = icon_dir .. 'bar/launcher.svg'
theme.icon_web_browser    = icon_dir .. 'bar/web-browser.svg'
theme.icon_text_editor    = icon_dir .. 'bar/text-editor.svg'
theme.icon_file_manager   = icon_dir .. 'bar/file-manager.svg'
theme.icon_terminal       = icon_dir .. 'bar/terminal.svg'
theme.icon_music_player   = icon_dir .. 'bar/lollypop.svg'
theme.icon_multimedia     = icon_dir .. 'bar/multimedia.svg'
theme.icon_store          = icon_dir .. 'bar/store.svg'
theme.icon_doc_viewer     = icon_dir .. 'bar/document-viewer.svg'
theme.icon_lock           = icon_dir .. 'lock.svg'
theme.icon_logout         = icon_dir .. 'logout.svg'
theme.icon_restart        = icon_dir .. 'restart.svg'
theme.icon_sleep          = icon_dir .. 'sleep.svg'
theme.icon_shutdown       = icon_dir .. 'shutdown.svg'
theme.icon_close          = icon_dir .. 'close.svg'
theme.icon_wifi_on        = icon_dir .. 'wifi.svg'
theme.icon_wifi_off       = icon_dir .. 'wifi-off.svg'
theme.icon_wifi_strengh_1 = icon_dir .. 'wifi-strengh-1.svg'
theme.icon_wifi_strengh_2 = icon_dir .. 'wifi-strengh-2.svg'
theme.icon_wifi_strengh_3 = icon_dir .. 'wifi-strengh-3.svg'
theme.icon_tethering      = icon_dir .. 'tethering.png'
theme.icon_bluetooth      = icon_dir .. 'bluetooth.svg'
theme.icon_arrow_up       = icon_dir .. 'arrow-up.svg'
theme.icon_arrow_down     = icon_dir .. 'arrow-down.svg'
theme.icon_arrow_left     = icon_dir .. 'arrow-left.svg'
theme.icon_arrow_right    = icon_dir .. 'arrow-right.svg'
theme.icon_sound          = icon_dir .. 'sound.svg'
theme.icon_sound_soft     = icon_dir .. 'sound-soft.svg'
theme.icon_sound_mute     = icon_dir .. 'sound-mute.svg'
theme.icon_done            = icon_dir .. 'done.png'
theme.icon_plus            = icon_dir .. 'plus.svg'
theme.icon_cpu             = icon_dir .. 'hardware-monitor/cpu.svg'
theme.icon_ram             = icon_dir .. 'hardware-monitor/ram.svg'
theme.icon_harddrive       = icon_dir .. 'hardware-monitor/harddrive.svg'
theme.icon_temperature     = icon_dir .. 'hardware-monitor/thermometer.svg'
theme.icon_toggled_on      = icon_dir .. 'toggled-on.png'
theme.icon_toggled_off     = icon_dir .. 'toggled-off.svg'
theme.icon_brightness      = icon_dir .. 'brightness.svg'
theme.icon_brightness_soft = icon_dir .. 'brightness-soft.svg'
theme.icon_list            = icon_dir .. 'list.svg'
theme.icon_center          = icon_dir .. 'center.png'
theme.icon_desktop         = icon_dir .. 'desktop.png'
theme.icon_desktop_active  = icon_dir .. 'desktop-active.png'
theme.icon_tasklist        = icon_dir .. 'tasklist.png'
theme.icon_separator       = icon_dir .. 'separator.png'
theme.icon_player_music    = icon_dir .. 'music-player/music.png'
theme.icon_player_play     = icon_dir .. 'music-player/play.png'
theme.icon_player_pause    = icon_dir .. 'music-player/pause.png'
theme.icon_player_next     = icon_dir .. 'music-player/next.png'
theme.icon_player_prev     = icon_dir .. 'music-player/prev.png'
theme.icon_taglist_home        = icon_dir .. 'taglist/home.png'
theme.icon_taglist_development = icon_dir .. 'taglist/development.png'
theme.icon_taglist_web_browser = icon_dir .. 'taglist/web-browser.png'
theme.icon_notification_new    = icon_dir .. 'notification/new.png'

-- Generate Awesome icon:
--theme.awesome_icon = theme_assets.awesome_icon(
--theme.menu_height, theme.bg_focus, theme.fg_focus
--)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.awesome_icon = dir .. 'awesome.svg'
theme.icon_theme = "Papirus"

return theme

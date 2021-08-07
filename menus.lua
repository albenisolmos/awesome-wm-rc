local awful = require("awful")
local beautiful = require("beautiful")
local apps = require 'apps'

menuBrowserFiles = awful.menu {
	items = {
		{ 'Desktop',  apps.filemanager .. ' Desktop' },
		{ 'Downloads',  apps.filemanager .. ' Downloads' },
		{ 'Documents', apps.filemanager .. ' Documents' },
		{ 'Pintures', apps.filemanager .. ' Pintures' },
		{ 'Musics', apps.filemanager .. ' Musics' }
	}
}

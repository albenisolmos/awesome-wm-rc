local amenu = require('awful.menu')
local beautiful = require('beautiful')
local apps = require('apps')

menuBrowserFiles = amenu {
	items = {
		{ 'Desktop',  apps.filemanager .. ' Desktop' },
		{ 'Downloads',  apps.filemanager .. ' Downloads' },
		{ 'Documents', apps.filemanager .. ' Documents' },
		{ 'Pintures', apps.filemanager .. ' Pintures' },
		{ 'Musics', apps.filemanager .. ' Musics' }
	}
}

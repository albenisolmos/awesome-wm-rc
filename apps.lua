local terminal = 'terminator'

return {
   terminal			= terminal,
   editor			= terminal .. ' -e vim',
   editor_CLI		= terminal .. ' -e vim',
   web_browser		= 'firefox',
   multimedia		= 'smplayer',
   filemanager		= 'nautilus',
   filemanager_CLI	= terminal .. ' -e ranger',
   calculator		= 'galculator',
   music_player		= 'lollypop',
   launcher           = 'rofi -show drun',
   network_manager	= 'wicd-gtk',
   sound_manager	= 'pavucontrol',
   package_manager	= 'synaptic-pkexec',
   doc_viewer      = 'evince'
}

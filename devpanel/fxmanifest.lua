fx_version 'cerulean'
game 'gta5'

name 'ay_devpanel'
author 'Codex'
description 'AY Panel with admin and developer tools for FiveM'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_script 'config.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

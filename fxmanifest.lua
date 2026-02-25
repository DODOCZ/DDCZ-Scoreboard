fx_version 'cerulean'
game 'gta5'

name        'ddcz-scoreboard'
version     '1.0.0'
author      'DDCZ Dev'
description 'Tactical HUD scoreboard for QBCore'


shared_scripts {
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
}

fx_version 'cerulean'
game 'gta5'

description 'QB Rob & Hostage System'
version '1.0.0'
author 'RoninDevelopment'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'ps-dispatch',
    'ox_lib'
}
lua54 'yes'

escrow_ignore {
    'config.lua'
}
fx_version 'cerulean'
game 'gta5'

author 'Gildas'
description 'Déconnexion en dormant sur un lit'
version '1.0.0'

client_scripts {
    'client.lua',
	'ox_lib.lua'
}

server_scripts {
    'server.lua',
}

dependencies {

   'esx_status',  -- Assurez-vous que esx_status est bien installé
   'ox_lib',
}

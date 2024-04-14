fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'collin1337'
description 'Give & Delete Vehicle Command for ESX Legacy'

server_scripts {
  '@oxmysql/lib/MySQL.lua',

  '@es_extended/imports.lua',

  'configs/config.lua',
  'configs/config_locales.lua',

  'server/functions.lua',
  'server/main.lua'
}
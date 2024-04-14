Config = {}

Config.Permissions = {
  ['GROUP_NAME'] = { -- ESX Group Name
    giveVehicle = true, -- true or false
    deleteVehicle = true -- true or false
  },
  -- ADD MORE
}

Config.WebhookSettings = {
  ['user'] = { -- Change User Settings for the Webhook
    name = 'EXAMPLE', -- Name
    icon_url = 'IMAGE OR GIF LINK' -- Icon URL (!) REQUIRED (!)
  },

  ['embed'] = { -- Change Embed Settings
    ['author'] = { -- Author
      name = 'EXAMPLE', -- Name
      icon_url = 'IMAGE OR GIF LINK' -- Icon URL (!) REQUIRED (!)
    },
    ['color'] = '16711680', -- Color [https://www.spycolor.com/ff0000 / Decimal value]
    ['thumbnail'] = { -- Thumnbail
      url = 'IMAGE OR GIF LINK' -- URL (!) REQUIRED (!)
    }
  }
}

Config.Webhooks = {
  ['giveVehicle'] = 'https://discord.com/api/webhooks/', -- Webhook URL (Give Vehicle)
  ['deleteVehicle'] = 'https://discord.com/api/webhooks/' -- Webhook URL (Delete Vehicle)
}
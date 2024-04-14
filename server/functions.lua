local NumberCharset = {}
local Charset = {}

for i = 48, 57 do table.insert(NumberCharset, string.char(i)) end
for i = 65, 90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function PlayerHasPermission(player, perm) -- Checks if Player has Permission
  local xPlayer = ESX.GetPlayerFromId(player)

  for index, data in pairs(Config.Permissions) do
    if index == xPlayer.getGroup() then
      if data[perm] then
        return true
      end
    end
  end

  return false
end

function GeneratePlate() -- Generates Plate
  local vehPlate
  local canBreak = false

  while true do
    Citizen.Wait(2)
    math.randomseed(GetGameTimer())

    vehPlate = string.upper(GetRandomLetter(3) .. ' ' .. GetRandomNumber(3))

    local results = MySQL.query.await('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
      ['@plate'] = vehPlate
    })

    if not results[1] then
      canBreak = true
    end

    if canBreak then
      break
    end
  end

  return vehPlate
end

function IsPlateTaken(vehPlate) -- Checks if Plate is Taken
  local results = MySQL.query.await('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
    ['@plate'] = vehPlate
  })

  if results[1] then
    return true
  end

  return false
end

function GetRandomNumber(length)
  Citizen.Wait(1)
  math.randomseed(GetGameTimer())

  if length > 0 then
    return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
  else
    return ''
  end
end

function GetRandomLetter(length)
  Citizen.Wait(1)
  math.randomseed(GetGameTimer())

  if length > 0 then
    return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
  else
    return ''
  end
end

function GetPlayerNameForDiscord(player) -- Discord Help
  local playerName
  local playerId = player

  if player == 0 or player == nil then
    playerName = 'Console'
    playerId = ''
  else
    if GetPlayerName(player) then
      playerName = GetPlayerName(player)
      playerId = '['.. player ..']'
    else
      playerName = 'Not Found / Unkown'
      playerId = ''
    end
  end

  return playerName .. ' ' .. playerId
end

function GetPlayerIdentifiersForDiscord(player) -- Discord Help
  if player == 0 or player == nil then
    return 'Not Found / Unkown' .. '\n' .. 'Not Found / Unkown' .. '\n' .. 'Not Found / Unkown'
  else
    return (GetPlayerIdentifierByType(player, 'steam') or 'Not Found / Unkown') .. '\n' .. (GetPlayerIdentifierByType(player, 'discord') or 'Not Found / Unkown') .. '\n' .. (GetPlayerIdentifierByType(player, 'license') or 'Not Found / Unkown')
  end
end

function DiscordSendLog(discordWebhook, embedTitel, embedFields) -- Function for Discord Webhook Log
  local discordWebhook = Config.Webhooks[discordWebhook]

  local DISCORD = {
    {
      ['author'] = {
        name = Config.WebhookSettings.embed.author.name,
        url = 'https://linktr.ee/collin1337',
        icon_url = Config.WebhookSettings.embed.author.icon_url
      },
      ['color'] = Config.WebhookSettings.embed.color,
      ['title'] = embedTitel .. ' | ' .. GetCurrentResourceName(),
      ['fields'] = embedFields,
      ['thumbnail'] = {
        url = Config.WebhookSettings.embed.thumbnail.url
      },
      ['footer'] = {
        text = 'by collin1337',
        icon_url = 'https://collin1337.com/attachments/custom/collin1337.gif'
      }
    }
  }

  PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({ username = Config.WebhookSettings.user.name, avatar_url = Config.WebhookSettings.user.icon_url, embeds = DISCORD }), { ['Content-Type'] = 'application/json' })
end

function GiveVehicleToPlayer(targetId, vehType, vehName, vehPlate, source) -- Gives a Vehicle to a Player
  MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)', {
    ['@owner'] = ESX.GetIdentifier(targetId),
    ['@plate'] = string.upper(vehPlate),
    ['@vehicle'] = '{"plate":"'.. vehPlate ..'", "model":'.. joaat(vehName) ..'}',
    ['@stored'] = 1,
    ['type'] = vehType
  }, function(rowsChanged)
    if rowsChanged > 0 then
      DiscordSendLog('giveVehicle', 'Give Vehicle', {
        { name = 'Admin Name:', value = '```'.. GetPlayerNameForDiscord(source) ..'```', inline = false },
        { name = 'Admin Identifiers:', value = '```'.. GetPlayerIdentifiersForDiscord(source) ..'```', inline = false },
        { name = 'Player Name:', value = '```'.. GetPlayerNameForDiscord(targetId) ..'```', inline = false },
        { name = 'Player Identifiers:', value = '```'.. GetPlayerIdentifiersForDiscord(targetId) ..'```', inline = false },
        { name = 'Vehicle Type:', value = '```'.. vehType ..'```', inline = true },
        { name = 'Vehicle Name:', value = '```'.. vehName ..'```', inline = true },
        { name = 'Vehicle Plate:', value = '```'.. vehPlate ..'```', inline = true },
        { name = 'Date:', value = '```'.. os.date('%d.%m.%Y - %X') ..'```', inline = false }
      })
    end
  end)
end

function DeleteVehicleFromPlayer(vehPlate, source, isConsole) -- Deletes a Vehicle from a Player
  MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
    ['@plate'] = string.upper(vehPlate)
  }, function(rowsChanged)
    if rowsChanged > 0 then
      DiscordSendLog('deleteVehicle', 'Deleted Vehicle', {
        { name = 'Admin Name:', value = '```'.. GetPlayerNameForDiscord(source) ..'```', inline = false },
        { name = 'Admin Identifiers:', value = '```'.. GetPlayerIdentifiersForDiscord(source) ..'```', inline = false },
        { name = 'Vehicle Plate:', value = '```'.. vehPlate ..'```', inline = false },
        { name = 'Date:', value = '```'.. os.date('%d.%m.%Y - %X') ..'```', inline = false }
      })

      if isConsole then
        print('^3DeleteVehicleFromPlayer^0()' .. ' - ^3Plate^0: ^5' .. vehPlate .. '^0')
      else
        TriggerClientEvent('esx:showNotification', source, string.format(Locales['deletedVehicle'], string.upper(vehPlate)))
      end
    else
      if isConsole then
        print('^3DeleteVehicleFromPlayer^0()' .. ' - ^3Plate^0: ^5' .. vehPlate .. ' ^0Does not Exists')
      else
        TriggerClientEvent('esx:showNotification', source, string.format(Locales['plateDoesNotExists'], string.upper(vehPlate)))
      end
    end
  end)
end
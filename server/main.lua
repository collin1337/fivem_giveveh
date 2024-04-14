RegisterCommand('giveveh', function(source, args) -- Give Vehicle Command [/giveveh ID TYPE VEHICLE PLATE]
  if source == 0 then
    local targetId = tonumber(args[1])

    if GetPlayerName(targetId) then
      local vehType, vehName, vehPlate = args[2], args[3], args[4]

      if vehType ~= 'car' and vehType ~= 'boat' and vehType ~= 'helicopter' and vehType ~= 'airplane' then
        return print('^1Invalid Type^0: ^3'.. vehType ..'^0 | ^2Valid Types^0: ^3car^0, ^3boat^0, ^3helicopter^0, ^3airplane^0')
      end

      if vehPlate == nil then
        vehPlate = GeneratePlate()
      end

      if string.len(vehPlate) > 8 then
        return print('^3Plate^0: "^5'.. vehPlate ..'^0" is to ^1Long^0 [^2MAX LENGTH 8^0]')
      end

      if IsPlateTaken(vehPlate) then
        return print('^3Plate^0: "^5'.. vehPlate ..'^0" is already Taken')
      end

      GiveVehicleToPlayer(targetId, vehType, vehName, vehPlate, source)
      print('^3GiveVehicleToPlayer^0()' .. ' - ^3Target^0: ^5' .. GetPlayerName(targetId) .. ' - ['.. targetId ..']' .. '^3 Type^0: ^5' .. vehType .. '^3 Name^0: ^5' .. string.upper(vehName) .. '^3 Plate^0: ^5' .. string.upper(vehPlate) .. '^0')
      TriggerClientEvent('esx:showNotification', targetId, string.format(Locales['receivedVehicle'], string.upper(vehName), string.upper(vehPlate)))
    else
      print('Unkown Player ID - ^5'.. targetId ..'^0')
    end
  else
    if PlayerHasPermission(source, 'giveVehicle') then
      local targetId = tonumber(args[1])

      if GetPlayerName(targetId) then
        local vehType, vehName, vehPlate = args[2], args[3], args[4]

        if vehType ~= 'car' and vehType ~= 'boat' and vehType ~= 'helicopter' and vehType ~= 'airplane' then
          return TriggerClientEvent('esx:showNotification', source, string.format(Locales['invalidVehicleType'], vehType))
        end

        if vehPlate == nil then
          vehPlate = GeneratePlate()
        end

        if string.len(vehPlate) > 8 then
          return TriggerClientEvent('esx:showNotification', source, string.format(Locales['vehiclePlateMax'], string.upper(vehPlate)))
        end

        if IsPlateTaken(vehPlate) then
          return TriggerClientEvent('esx:showNotification', source, string.format(Locales['plateIsTaken'], string.upper(vehPlate)))
        end

        GiveVehicleToPlayer(targetId, vehType, vehName, vehPlate, source)
        TriggerClientEvent('esx:showNotification', source, string.format(Locales['givedVehicle'], string.upper(vehPlate), GetPlayerName(targetId)))
        TriggerClientEvent('esx:showNotification', targetId, string.format(Locales['receivedVehicle'], string.upper(vehName), string.upper(vehPlate)))
      else
        TriggerClientEvent('esx:showNotification', source, string.format(Locales['playerNotOnline'], targetId))
      end
    end
  end
end)

RegisterCommand('deleteveh', function(source, args) -- Delete Vehicle Command [/deleteveh PLATE]
  if source == 0 then
    local vehPlate = table.concat(args, ' ')

    if string.len(vehPlate) > 8 then
      return print('^3Plate^0: "^5'.. vehPlate ..'^0" is to ^1Long^0 [^2MAX LENGTH 8^0]')
    end

    DeleteVehicleFromPlayer(vehPlate, source, true)
  else
    if PlayerHasPermission(source, 'deleteVehicle') then
      local vehPlate = table.concat(args, ' ')

      if string.len(vehPlate) > 8 then
        return TriggerClientEvent('esx:showNotification', source, string.format(Locales['vehiclePlateMax'], string.upper(vehPlate)))
      end

      DeleteVehicleFromPlayer(vehPlate, source, false)
    end
  end
end)
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
	MySQL.Async.execute("UPDATE owned_vehicles SET impound = 1 WHERE owner != 'parking' AND impound != 2 AND impound != 3")
end)

ESX.RegisterServerCallback("tow:list", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local vehList = {}

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @idf AND impound = 1", {
		["@idf"] = xPlayer.identifier
	}, function(results)
		for k,v in pairs(results) do
			local vehicle = json.decode(v.vehicle)
			table.insert(vehList, { vehicle = vehicle, plate = v.plate })
		end
		cb(vehList)
	end)
end)

ESX.RegisterServerCallback("tow:listlspd", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local vehList = {}

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @idf AND impound = 2", {
		["@idf"] = xPlayer.identifier
	}, function(results)
		for k,v in pairs(results) do
			local vehicle = json.decode(v.vehicle)
			table.insert(vehList, { vehicle = vehicle, plate = v.plate })
		end
		cb(vehList)
	end)
end)

RegisterServerEvent("tow:unimp")
AddEventHandler("tow:unimp", function(plate)
	local plt = plate:upper()
	MySQL.Async.execute("UPDATE owned_vehicles SET impound = 0 WHERE plate = @plate", {
		["@plate"] = plt
	})
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(200)
	--MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = 'char2:ae2e5d924aeba9669a2a1282548aaa1eeda8e4bb'", function(govResult)
	--	local acc = govResult[1].accounts
	--	local bank = split(acc, "bank")
	--	local addmoney = bank[1]..""
	--	MySQL.Async.execute("SELECT * FROM users WHERE identifier = 'char2:ae2e5d924aeba9669a2a1282548aaa1eeda8e4bb'", function(govResult)
	--	
	--	end)
	--end)
end)

RegisterServerEvent("tow:imp")
AddEventHandler("tow:imp", function(plate)
	local plt = plate:upper()
	MySQL.Async.execute("UPDATE owned_vehicles SET impound = 1 WHERE plate = @plate", {
		["@plate"] = plt
	})
	xPlayer.addMoney(30)
end)

RegisterServerEvent("tow:implspd")
AddEventHandler("tow:implspd", function(plate)
	local plt = plate:upper()
	MySQL.Async.execute("UPDATE owned_vehicles SET impound = 2 WHERE plate = @plate", {
		["@plate"] = plt
	})
end)

RegisterServerEvent("tow:unimplspd")
AddEventHandler("tow:unimplspd", function(plate)
	local plt = plate:upper()
	MySQL.Async.execute("UPDATE owned_vehicles SET impound = 0 WHERE plate = @plate", {
		["@plate"] = plt
	})
end)

RegisterServerEvent("tow:srt")
AddEventHandler("tow:srt", function(idf, plate)
	local plt = plate:upper()
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", {
		["@plate"] = plt
	}, function(results)
		if results[1].owner == idf then
			MySQL.Async.execute("DELETE FROM owned_vehicles WHERE plate = @plate", {
				["@plate"] = plt
			})
		else
			MySQL.Async.execute("UPDATE owned_vehicles SET impound = 1 WHERE plate = @plate", {
				["@plate"] = plt
			})
		end
	end)
end)

RegisterCommand("respawnallvehicles", function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getGroup() == "admin" then
		MySQL.Async.execute("UPDATE owned_vehicles SET impound = 1 WHERE owner != 'parking' AND impound != 2 AND impound != 3")
	end
end)

RegisterCommand("aimpound", function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	local  plt = args[1]:upper()
	if xPlayer.getGroup() == "admin" then
		MySQL.Async.execute("UPDATE owned_vehicles SET impound = 1 WHERE plate = @plate AND impound != 2 AND impound != 3", {
			["@plate"] = plt
		})
	end
end)


RegisterServerEvent('tow:srt1')
AddEventHandler("tow:srt1", function(idf, plate)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
		["@owner"] = idf,
		["@plate"] = plate
	},function(result)
		if result then
			TriggerEvent("tow:srt", plate)
		end
	end)
end)

function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

Locale = {
    ["TowedVehicles"] = "Odtáhnutá vozidla",
    ["ImpoundedVehicles"] = "Zabavená vozidla",
    ["ListOfTowedVehicles"] = "Seznam odtažených vozidel",
    ["ReleaseTheVehicle"] = "Uvolnit vozidlo",
    ["Vehicle"] = "Vozidlo ",
    ["YouAreInVehicle"] = "Nesmíš být v aute",
    ["YouPaid"] = "Zaplatil jsi správci odtahu ~r~$",
    ["Unimpound"] = "Uvolnit",
    ["Onlypolice"] = "Pouze ~b~LSPD~w~!",
    ["WasReleased"] = "bylo uvolneno",
    ["WasConfiscatedByThePolice"] = " bylo ~y~zabavené ~b~policií~w~!",
    ["GetMoney"] = "Správce odtahu ti zaplatil ~g~$30~w~ za odtažené vozidlo!",
    ["Garage"] = "Garáž",
    ["ParkHere"] = "Zaparkovat",
    ["Towtruck"] = "Odtahovka",
    ["TowGarage"] = 'Odtahová garáž',
    ["VehicleIsParked"] = 'Vozidlo zaparkováno',
    ["ThisIsNotTowtruck"] = 'Toto není ~y~~h~odtahové vozidlo',
    ["ScrapYard"] = "Vrakovište",
    ["DontScrap"] = "Ještě si to rozmyslím",
    ["Scrap"] = "Nechat sešrotovat",
    ["VehicleWasScraped"] = "Auto ~r~sešrotováno~w~!",
    ["Goaway"] = "Tak ~y~odchod~w~!",
    ["PutVehicleHere"] = "Postav sem auto které chceš nechat sešrotovat"

}
Command = {
    ["Impound"] = "impound" -- Command for impound vehicle
}

Scrapscript = true -- If you want to activate the scrap yard









ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(0)
    end
end)

CreateThread(function()
    while true do
        PlayerData = ESX.GetPlayerData()
        TowSpawn = vector3(384.809, -1622.801, 29.29)
        scrap = vector3(-461.02, -1711.16, 18.15)
        LSPDTow = vector3(369.90, -1608.18, 29.29)
        TowCar = vector3(401.25, -1631.92, 28.75)
        coords = GetEntityCoords(PlayerPedId())
        onFoot = IsPedOnFoot(PlayerPedId())
        Citizen.Wait(0)
    end
end)
local price = 200
CreateThread(function()
    while true do   
        Citizen.Wait(0)
        local distance = #(coords-TowSpawn)
        if distance <= 20 then
            DrawMarker(36, TowSpawn.x, TowSpawn.y, TowSpawn.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 100, 255, 100, false, true, 0, false)
            if distance <= 1.5 then
                if onFoot then
                    ESX.ShowHelpNotification("~INPUT_CONTEXT~ "..Locale.TowedVehicles)
                    if IsControlJustReleased(0, 38) then
                        OpenVehicleListTow()
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do   
        Citizen.Wait(0)
        local distance = #(coords-LSPDTow)
        if distance <= 20 then
            DrawMarker(36, LSPDTow.x, LSPDTow.y, LSPDTow.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 100, 255, 100, false, true, 0, false)
            if distance <= 1.5 then
                if onFoot then
                    ESX.ShowHelpNotification("~INPUT_CONTEXT~ "..Locale.ImpoundedVehicles)
                    if IsControlJustReleased(0, 38) then
                        OpenVehicleListLSPD()
                    end
                end
            end
        end
    end
end)

function OpenVehicleListTow()
    local elements = {}
    ESX.TriggerServerCallback("tow:list", function(vehList)
        for k,v in pairs(vehList) do
            local vehHash = v.vehicle.model
            local vehName = GetDisplayNameFromVehicleModel(vehHash)
            local vehLabel = GetLabelText(vehName)
            table.insert(elements, { label = v.plate, name = vehName, value = v, plate = v.plate, vehicle = v.vehicle })
        end
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "towListGarage", {
            title = Locale.ListOfTowedVehicles,
            align = "right",
            elements = elements
        }, function(data, menu)
            OpenVehicleInfoDisplay(data.current)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end)
end

function OpenVehicleListLSPD()
    local elements = {}
    ESX.TriggerServerCallback("tow:listlspd", function(vehList)
        for k,v in pairs(vehList) do
            local vehHash = v.vehicle.model
            local vehName = GetDisplayNameFromVehicleModel(vehHash)
            local vehLabel = GetLabelText(vehName)
            table.insert(elements, { label = v.plate, name = vehName, value = v, plate = v.plate, vehicle = v.vehicle })
        end
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "towListGarage", {
            title = Locale.ListOfTowedVehicles,
            align = "right",
            elements = elements
        }, function(data, menu)
            OpenVehicleInfoDisplayLSPD(data.current)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end)
end

function OpenVehicleInfoDisplay(info)
    local elements = {
        {label = Locale.ReleaseTheVehicle.." - $"..price, value = info.value}
    }

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "towListGarageSpawn", {
        title = Locale.Vehicle..info.plate,
        align = "right",
        elements = elements
    }, function(data, menu)
        if data.current.value ~= nil then
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                SpawnSelVeh(data.current.value)
            else
                ESX.ShowNotification(Locale.YouAreInVehicle)
            end
        end
    end, function(data, menu)
        menu.close()
        OpenVehicleListTow()
    end)
end

function OpenVehicleInfoDisplayLSPD(info)
    local elements = {
        {label = Locale.Unimpound, value = info.value}
    }

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "towListGarageSpawn", {
        title = Locale.Vehicle..info.plate,
        align = "right",
        elements = elements
    }, function(data, menu)
        if data.current.value ~= nil then
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if PlayerData.job.name == "police" then
                    SpawnSelVehLSPD(data.current.value)
                else
                    ESX.ShowNotification(Locale.Onlypolice)
                end
            else
                ESX.ShowNotification(Locale.YouAreInVehicle)
            end
        end
    end, function(data, menu)
        menu.close()
        OpenVehicleListTowLSPD()
    end)
end

function SpawnSelVeh(vehicle)
    ESX.Game.SpawnVehicle(vehicle.vehicle.model, vector3(TowSpawn.x+4.0, TowSpawn.y+4.0, TowSpawn.z), 310.89, function(car)
        ESX.Game.SetVehicleProperties(car, vehicle.vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
        Citizen.Wait(10)
        TriggerServerEvent("tow:unimp", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId())))
        ESX.UI.Menu.CloseAll()
        ESX.ShowNotification(Locale.YouPaid..price)
    end)
end

function SpawnSelVehLSPD(vehicle)
    ESX.Game.SpawnVehicle(vehicle.vehicle.model, vector3(TowSpawn.x+4.0, TowSpawn.y+4.0, TowSpawn.z), 310.89, function(car)
        ESX.Game.SetVehicleProperties(car, vehicle.vehicle)
        --TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
        Citizen.Wait(10)
        TriggerServerEvent("tow:unimplspd", vehicle.vehicle.plate)
        ESX.UI.Menu.CloseAll()
        ESX.ShowNotification(Locale.Vehicle.."~y~"..vehicle.vehicle.plate.."~w~ "..Locale.WasReleased)
    end)
end

RegisterCommand(Command.Impound, function(source, args, rawCommand)
    local distance = #(coords-TowCar)
    if distance <= 5 then
        if PlayerData.job.name == "tow" then
            TriggerServerEvent("tow:imp", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId())))
            ESX.ShowNotification(Locale.GetMoney)
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
        elseif PlayerData.job.name == "police" then
            TriggerServerEvent("tow:implspd", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId())))
            ESX.ShowNotification(Locale.Vehicle.."~y~"..GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId())).."~w~"..Locale.WasConfiscatedByThePolice)
            Citizen.Wait(10)
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
        end
    end
end)

CreateThread(function()
    while true do   
        Citizen.Wait(0)
        local distance = #(coords-TowCar)
        if distance <= 10 and ESX.GetPlayerData().job.name == 'tow' then
            DrawMarker(36, TowCar.x, TowCar.y, TowCar.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 100, 255, 100, false, true, 0, false)
            if distance <= 1.5 then
                if onFoot then
                    ESX.ShowHelpNotification("~INPUT_CONTEXT~ "..Locale.Garage)
                else
                    ESX.ShowHelpNotification("~INPUT_CONTEXT~ "..Locale.ParkHere)
                end
                if IsControlJustReleased(0, 38) then
                    if onFoot then
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), "vehicle", {
                            title    = Locale.Garage,
                            align    = 'top-right',
                            elements = {
                                {label = Locale.Towtruck, action = 'towtruck'}
                        }}, function(data, menu)
                        if data.current.action ~= '' then
                            ESX.Game.SpawnVehicle(data.current.action, vector3(TowCar.x, TowCar.y, TowCar.z), 134.69, function(vehicle)
                            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                            ESX.Game.SetVehicleProperties(vehicle, {
                                plate = "TOWTRUCK",
                                color1 = 61,
                                color2 = 61
                            })
                            ESX.UI.Menu.Close('default', GetCurrentResourceName(), "vehicle")
                            end)
                        end
                    end)
                    else
                        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId()))
                        if plate == "TOWTRUCK" then
                            --if GetIsVehicleEngineRunning(GetVehiclePedIsIn(PlayerPedId())) then
                            --    ESX.ShowAdvancedNotification('Vládní garáž', '~w~Vypni ~y~motor~w~!', 'Stiskni ~y~M', "CHAR_CALL911", 8)
                            --else
                                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                ESX.ShowAdvancedNotification(Locale.TowGarage, Locale.VehicleIsParked, "", "CHAR_MP_MERRYWEATHER", 8)
                           -- end
                        else
                            ESX.ShowAdvancedNotification(Locale.TowGarage, Locale.ThisIsNotTowtruck, "", "CHAR_BLOCKED", 8)
                        end
                    end
                end
            else
                ESX.UI.Menu.Close('default', GetCurrentResourceName(), "vehicle")
            end
        end
    end
end)

CreateThread(function()
    while true do   
        Citizen.Wait(0)
        local distance = #(coords-scrap)
        if distance <= 30 and Scrapscript == true then
            DrawMarker(1, scrap.x, scrap.y, scrap.z-1, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 2.0, 255, 0, 0, 100, false, true, 0, false)
            if distance <= 3 then
                if onFoot then
                    ESX.ShowHelpNotification(Locale.PutVehicleHere)
                else
                    ESX.ShowHelpNotification("~INPUT_CONTEXT~ "..Locale.Scrap)
                end
                if IsControlJustReleased(0, 38) then
                    if not onFoot then
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), "srt", {
                            title    = Locale.ScrapYard,
                            align    = 'top-right',
                            elements = {
                                {label = Locale.DontScrap, action = 'no'},
                                {label = Locale.Scrap, action = 'yes'}
                        }}, function(data, menu)
                        if data.current.action ~= '' then
                                if data.current.action == "yes" then
                                    DoScreenFadeOut(500)
                                    TriggerServerEvent("tow:srt", PlayerData.identifier, GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId())))
                                    ESX.ShowNotification(Locale.VehicleWasScraped)
                                    menu.close()
                                    Citizen.Wait(1000)
                                    DoScreenFadeIn(500)
                                    DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                elseif data.current.action == "no" then
                                    ESX.ShowNotification(Locale.Goaway)
                                    menu.close()
                                end
                        end
                        end, function(data, menu)
                            menu.close()
                        end)
                    end
                end
            end
        end                 
    end
end)
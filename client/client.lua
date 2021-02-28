

                          --(  ___ \ (  ___  )(  ____ \\__   __/(  ___  )( (    /|(  ____ \| \    /\\__   __/
                          --| (   ) )| (   ) || (    \/   ) (   | (   ) ||  \  ( || (    \/|  \  / /   ) (   
                          --| (__/ / | |   | || (_____    | |   | |   | ||   \ | || (_____ |  (_/ /    | |   
                          --|  __ (  | |   | |(_____  )   | |   | |   | || (\ \) |(_____  )|   _ (     | |   
                          --| (  \ \ | |   | |      ) |   | |   | |   | || | \   |      ) ||  ( \ \    | |   
                          --| )___) )| (___) |/\____) |   | |   | (___) || )  \  |/\____) ||  /  \ \___) (___
                          --|/ \___/ (_______)\_______)   )_(   (_______)|/    )_)\_______)|_/    \/\_______/
                                                                                 
  --_______  _______  ______   _______  _______ _________ _______  _______  _______    _   _    _______   _____    _____   _______ 
  ---|\     /|(  ____ \(  ____ )(  ___ \ (  ___  )(  ____ \\__   __/(  ___  )(  ____ )/ ___   )  ( ) ( )  (  __   ) / ___ \  / ___ \ (  ____ \
  --| )   ( || (    \/| (    )|| (   ) )| (   ) || (    \/   ) (   | (   ) || (    )|\/   )  | _| |_| |_ | (  )  |( (___) )( (   ) )| (    \/
  --| (___) || (__    | (____)|| (__/ / | (___) || |         | |   | (___) || (____)|    /   )(_   _   _)| | /   | \     / ( (___) || (____  
  --|  ___  ||  __)   |     __)|  __ (  |  ___  || |         | |   |  ___  ||     __)   /   /  _| (_) |_ | (/ /) | / ___ \  \____  |(_____ \ 
  ---| (   ) || (      | (\ (   | (  \ \ | (   ) || |         | |   | (   ) || (\ (     /   /  (_   _   _)|   / | |( (   ) )      ) |      ) )
  --| )   ( || (____/\| ) \ \__| )___) )| )   ( || (____/\___) (___| )   ( || ) \ \__ /   (_/\  | | | |  |  (__) |( (___) )/\____) )/\____) )
   --|/     \|(_______/|/   \__/|/ \___/ |/     \|(_______/\_______/|/     \||/   \__/(_______/  (_) (_)  (_______) \_____/ \______/ \______/ 

ESX = nil

local isUiOpen = false 
local object = 0
local TestLocalTable = {}
local editingNotpadId = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.50, 0.50)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.016, 0.025+ factor, 0.03, 41, 11, 41, 68)
end


RegisterNUICallback('escape', function(data, cb)
    local text = data.text
    TriggerEvent("boston_notepad:CloseNotepad")
end)

RegisterNUICallback('updating', function(data, cb)
    local text = data.text
    TriggerServerEvent("server:updateNote",editingNotpadId, text)
    editingNotpadId = nil
    TriggerEvent("boston_notepad:CloseNotepad")
end)

RegisterNUICallback('droppingEmpty', function(data, cb)
end)

RegisterNUICallback('dropping', function(data, cb)
    local text = data.text
    local location = GetEntityCoords(GetPlayerPed(-1))
    TriggerServerEvent("server:newNote",text,location["x"],location["y"],location["z"])
    TriggerEvent("boston_notepad:CloseNotepad")
end)

RegisterNetEvent("boston_notepad:OpenNotepadGui")
AddEventHandler("boston_notepad:OpenNotepadGui", function()
    if not isUiOpen then
        openGui()
    end
end)

RegisterNetEvent("boston_notepad:CloseNotepad")
AddEventHandler("boston_notepad:CloseNotepad", function()
    SendNUIMessage({
        action = 'closeNotepad'
    })
    SetPlayerControl(PlayerId(), 1, 0)
    isUiOpen = false
    SetNuiFocus(false, false);
    TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
    Citizen.Wait(100)
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(prop, 1, 1)
    DeleteObject(prop)
    DetachEntity(secondaryprop, 1, 1)
    DeleteObject(secondaryprop)
end)

RegisterNetEvent('boston_notepad:note')
AddEventHandler('boston_notepad:note', function()
    local player = PlayerPedId()
    local ad = "missheistdockssetup1clipboard@base"
                
    local prop_name = prop_name or 'prop_notepad_01'
    local secondaryprop_name = secondaryprop_name or 'prop_pencil_01'
    
    if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
        loadAnimDict( ad )
        if ( IsEntityPlayingAnim( player, ad, "base", 3 ) ) then 
            TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
            Citizen.Wait(100)
            ClearPedSecondaryTask(PlayerPedId())
            DetachEntity(prop, 1, 1)
            DeleteObject(prop)
            DetachEntity(secondaryprop, 1, 1)
            DeleteObject(secondaryprop)
        else
            local x,y,z = table.unpack(GetEntityCoords(player))
            prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
            secondaryprop = CreateObject(GetHashKey(secondaryprop_name), x, y, z+0.2,  true,  true, true)
            AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true) -- boston_notepadpad
            AttachEntityToEntity(secondaryprop, player, GetPedBoneIndex(player, 58866), 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true) -- pencil
            TaskPlayAnim( player, ad, "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
        end     
    end
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

RegisterNetEvent('boston_notepad:updateNotes')
AddEventHandler('boston_notepad:updateNotes', function(serverNotesPassed)
    TestLocalTable = serverNotesPassed
end)

function openGui() 
    local veh = GetVehiclePedIsUsing(GetPlayerPed(-1))  
    if GetPedInVehicleSeat(veh, -1) ~= GetPlayerPed(-1) then
        SetPlayerControl(PlayerId(), 0, 0)
        SendNUIMessage({
            action = 'openNotepad',
        })
        isUiOpen = true
        SetNuiFocus(true, true);
    end
end

function openGuiRead(text)
  local veh = GetVehiclePedIsUsing(GetPlayerPed(-1))
  if GetPedInVehicleSeat(veh, -1) ~= GetPlayerPed(-1) then
        SetPlayerControl(PlayerId(), 0, 0)
        TriggerEvent("boston_notepad:note")
        isUiOpen = true
        Citizen.Trace("OPENING")
        SendNUIMessage({
            action = 'openNotepadRead',
            TextRead = text,
        })
        SetNuiFocus(true, true)
  end  
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if #TestLocalTable == 0 then
            Citizen.Wait(1000)
        else
            local closestNoteDistance = 900.0
            local closestNoteId = 0
            local plyLoc = GetEntityCoords(GetPlayerPed(-1))
            for i = 1, #TestLocalTable do
                local distance = GetDistanceBetweenCoords(plyLoc["x"], plyLoc["y"], plyLoc["z"], TestLocalTable[i]["x"],TestLocalTable[i]["y"],TestLocalTable[i]["z"], true)
                if distance < 10.0 then
                    DrawMarker(27, TestLocalTable[i]["x"],TestLocalTable[i]["y"],TestLocalTable[i]["z"]-0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 2.0, 255, 255,150, 75, 0, 0, 2, 0, 0, 0, 0)
                end

                if distance < closestNoteDistance then
                  closestNoteDistance = distance
                  closestNoteId = i
                end
            end

            if closestNoteDistance > 100.0 then
                Citizen.Wait(math.ceil(closestNoteDistance*10))
            end

            if TestLocalTable[closestNoteId] ~= nil then
            local distance = GetDistanceBetweenCoords(plyLoc, TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"], true)
            if distance < 2.0 then
                DrawMarker(27, TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"]-0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 2.0, 255, 255, 155, 75, 0, 0, 2, 0, 0, 0, 0)
                DrawText3Ds(TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"]-0.4, "~g~[E]~s~ przeczytaj ~g~[X]~s~ zniszcz")

                if IsControlJustReleased(0, 38) then
                    openGuiRead(TestLocalTable[closestNoteId]["text"])
                    exports['mythic_notify']:DoCustomHudText('success', 'Podniosłeś notes', 3000)
                    editingNotpadId = closestNoteId
                end
                if IsControlJustReleased(0, 73) then
                  TriggerServerEvent("server:destroyNote",closestNoteId)
                  exports['mythic_notify']:DoCustomHudText('error', 'Zniszczyłeś notes', 3000)
                  table.remove(TestLocalTable,closestNoteId)
                end

            end
          else
            if TestLocalTable[closestNoteId] ~= nil then
              table.remove(TestLocalTable,closestNoteId)
            end
          end 

        end
    end 
end)

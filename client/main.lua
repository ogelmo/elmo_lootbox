local modelCrate = GetHashKey("xm3_prop_xm3_crate_01a")
local modelCan = GetHashKey("xm3_prop_xm3_can_hl_01a")
local modelCrowbar = GetHashKey("w_me_crowbar")
local modelCrateAfter = GetHashKey("xm3_prop_xm3_crate_01b")
local objectCrate, objectCan, objectCrowbar = nil, nil, nil

local function GetGroundZ(x, y, z)
    local groundZ = z
    local rayHandle = StartShapeTestRay(x, y, z + 50.0, x, y, z - 100.0, 10, PlayerPedId(), 0)
    local _, hit, hitX, hitY, hitZ, _, _ = GetShapeTestResult(rayHandle)
    if hit then
        return hitZ
    else
        return z
    end
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(1)
    end
end

local function createObjectOnGround(model, x, y, z, offset)
    local groundZ = GetGroundZ(x, y, z)
    local obj = CreateObject(model, x + (offset and offset.x or 0), y + (offset and offset.y or 0), groundZ + (offset and offset.z or 0), true, true, true)
    if DoesEntityExist(obj) then
        FreezeEntityPosition(obj, true)
        print("Obiekt " .. model .. " został pomyślnie stworzony.")
    else
        print("Błąd: Nie udało się stworzyć obiektu " .. model)
    end
    return obj
end

local function StartLootingScene()
    if not DoesEntityExist(objectCrate) then
        print("Błąd: Obiekt skrzyni nie istnieje.")
        return
    end

    local ped = PlayerPedId()
    local px, py, pz = table.unpack(GetEntityCoords(objectCrate))
    local rx, ry, rz = table.unpack(GetEntityRotation(objectCrate))
    
    loadAnimDict("anim@scripted@player@mission@trn_ig1_loot@male@")

    local scene = NetworkCreateSynchronisedScene(px, py, pz, rx, ry, rz, 2, true, false, -1, 0, 1.0)
    
    NetworkAddPedToSynchronisedScene(ped, scene, "anim@scripted@player@mission@trn_ig1_loot@male@", "loot", 1.5, -4.0, 1, 16, 1148846080, 0)

    if DoesEntityExist(objectCrate) then
        NetworkAddEntityToSynchronisedScene(objectCrate, scene, "anim@scripted@player@mission@trn_ig1_loot@male@", "loot_crate", 1.0, 1.0, 1)
    end
    if DoesEntityExist(objectCan) then
        NetworkAddEntityToSynchronisedScene(objectCan, scene, "anim@scripted@player@mission@trn_ig1_loot@male@", "loot_can", 1.0, 1.0, 1)
    end
    if DoesEntityExist(objectCrowbar) then
        NetworkAddEntityToSynchronisedScene(objectCrowbar, scene, "anim@scripted@player@mission@trn_ig1_loot@male@", "loot_crowbar", 1.0, 1.0, 1)
    end

    NetworkStartSynchronisedScene(scene)

    local animDur = GetAnimDuration("anim@scripted@player@mission@trn_ig1_loot@male@", "loot") * 1000
    Wait(animDur)

    NetworkStopSynchronisedScene(scene)

    if DoesEntityExist(objectCrate) then
        DeleteObject(objectCrate)
        local groundZ = GetGroundZ(px, py, pz)
        objectCrate = CreateObject(modelCrateAfter, px, py, groundZ, true, true, true)
        FreezeEntityPosition(objectCrate, true)
        print("Skrzynia została zamieniona na nową.")
    end

    if DoesEntityExist(objectCrowbar) then
        DeleteObject(objectCrowbar)
        print("Crowbar został usunięty.")
    end
    TriggerServerEvent('Lootadd')
end

exports.ox_target:addModel(modelCrate, {
    label = 'Otwórz skrzynie',
    name = 'box',
    icon = 'fa-solid fa-box',    
    distance = 2,
    canInteract = function()
        return exports.ox_inventory:GetItemCount('weapon_crowbar') > 0
    end,
    onSelect = function ()
        StartLootingScene()
    end
})

CreateThread(function()
    RequestModel(modelCrate)
    RequestModel(modelCan)
    RequestModel(modelCrowbar)
    RequestModel(modelCrateAfter)
    while not HasModelLoaded(modelCrate) or not HasModelLoaded(modelCan) or not HasModelLoaded(modelCrowbar) or not HasModelLoaded(modelCrateAfter) do
        Wait(1)
    end

    local x, y, z = -567.5618, -1023.5364, 22.1781 - 1
    local groundZ = GetGroundZ(x, y, z)
    
    objectCrate = CreateObject(modelCrate, x, y, groundZ, true, true, true)
    
    local offsetCan = { x = 0.0, y = 0.0, z = 0.3 }
    objectCan = createObjectOnGround(modelCan, x, y, groundZ, offsetCan)
    
    local offsetCrowbar = { x = 0.1, y = 0.0, z = 0.3 }
    objectCrowbar = createObjectOnGround(modelCrowbar, x, y, groundZ, offsetCrowbar)

    if DoesEntityExist(objectCrate) and DoesEntityExist(objectCan) and DoesEntityExist(objectCrowbar) then
        print("Obiekty zostały pomyślnie stworzone.")
        FreezeEntityPosition(objectCrate, true)
        FreezeEntityPosition(objectCan, true)
        FreezeEntityPosition(objectCrowbar, true)
    else
        print("Błąd: Nie udało się stworzyć obiektów.")
        return
    end
end)

SetModelAsNoLongerNeeded(modelCrate)
SetModelAsNoLongerNeeded(modelCan)
SetModelAsNoLongerNeeded(modelCrowbar)
SetModelAsNoLongerNeeded(modelCrateAfter)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if DoesEntityExist(objectCrate) then
        DeleteObject(objectCrate)
    end
    if DoesEntityExist(objectCan) then
        DeleteObject(objectCan)
    end
    if DoesEntityExist(objectCrowbar) then
        DeleteObject(objectCrowbar)
    end
end)
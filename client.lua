local QBCore = exports['qb-core']:GetCoreObject()

local currentHostage = nil
local isHoldingHostage = false
local lastRobTime = 0
local lastHostageTime = 0

-- Utility Functions
local function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

local function ShowNotification(msg)
    QBCore.Functions.Notify(msg, 'primary', 5000)
end

local function HasRequiredWeapon(actionType)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    
    for _, allowedWeapon in ipairs(Config.RequiredWeapons[actionType]) do
        if GetHashKey(allowedWeapon) == weapon then
            return true
        end
    end
    return false
end

local function IsOnCooldown(actionType)
    if actionType == "Rob" and lastRobTime == 0 then return false end
    if actionType == "Hostage" and lastHostageTime == 0 then return false end

    local currentTime = GetGameTimer()
    local cooldownTime = Config.Cooldowns[actionType] * 60000
    
    if actionType == "Rob" then
        local timeElapsed = currentTime - lastRobTime
        return timeElapsed < cooldownTime
    else
        local timeElapsed = currentTime - lastHostageTime
        return timeElapsed < cooldownTime
    end
end

local function GetCopCount(cb)
    QBCore.Functions.TriggerCallback('rd-robhostage:server:getCopCount', function(count)
        cb(count)
    end)
end

-- Global Functions for qb-target access
RobPerson = function(targetPed)
    if not DoesEntityExist(targetPed) then return end
    if IsPedDeadOrDying(targetPed) then return end
    
    GetCopCount(function(copCount)
        if copCount < Config.RequiredCops.Rob then
            ShowNotification("Not enough police in the city!")
            return
        end
        
        if not HasRequiredWeapon("Rob") then
            ShowNotification("You need a weapon to rob someone!")
            return
        end
        
        if IsOnCooldown("Rob") then
            ShowNotification("You must wait before robbing again!")
            return
        end

        local ped = PlayerPedId()
        
        -- Prevent NPC from fleeing
        SetBlockingOfNonTemporaryEvents(targetPed, true)
        SetPedFleeAttributes(targetPed, 0, false)
        ClearPedTasksImmediately(targetPed)
        
        -- Load animations
        LoadAnimDict(Config.Animations.Rob.dict)
        LoadAnimDict(Config.Animations.Rob.victimDict)
        
        -- Play animations
        TaskPlayAnim(targetPed, Config.Animations.Rob.victimDict, Config.Animations.Rob.victimAnim, 8.0, -8.0, -1, 1, 0, false, false, false)
        TaskPlayAnim(ped, Config.Animations.Rob.dict, Config.Animations.Rob.anim, 8.0, -8.0, -1, 49, 0, false, false, false)
        
        -- Dispatch
        exports['ps-dispatch']:CustomAlert({
            coords = GetEntityCoords(ped),
            message = Config.Dispatch.Rob.description,
            dispatchCode = Config.Dispatch.Rob.code,
            priority = 1,
            sprite = Config.Dispatch.Rob.blipSprite,
            color = Config.Dispatch.Rob.blipColor,
            scale = Config.Dispatch.Rob.blipScale,
            length = Config.Dispatch.Rob.blipLength,
        })

        QBCore.Functions.Progressbar("robbing_person", "Robbing...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            TriggerServerEvent('rd-robhostage:server:getRobbedItems')
            lastRobTime = GetGameTimer()
            
            ClearPedTasks(ped)
            ClearPedTasks(targetPed)
            
            -- Make NPC flee after robbery
            SetBlockingOfNonTemporaryEvents(targetPed, false)
            SetPedFleeAttributes(targetPed, 1, true)
            TaskSmartFleePed(targetPed, ped, 100.0, -1, true, true)
        end)
    end)
end

StartHostage = function(targetPed)
    if not DoesEntityExist(targetPed) then return end
    if IsPedDeadOrDying(targetPed) then return end

    GetCopCount(function(copCount)
        if copCount < Config.RequiredCops.Hostage then
            ShowNotification("Not enough police in the city!")
            return
        end
        
        if not HasRequiredWeapon("Hostage") then
            ShowNotification("You need a weapon to take a hostage!")
            return
        end
        
        if IsOnCooldown("Hostage") then
            ShowNotification("You must wait before taking another hostage!")
            return
        end

        local ped = PlayerPedId()
        
        -- Prevent NPC from fleeing
        SetBlockingOfNonTemporaryEvents(targetPed, true)
        SetPedFleeAttributes(targetPed, 0, false)
        ClearPedTasksImmediately(targetPed)

        -- Load animations
        LoadAnimDict(Config.Animations.Hostage.dict)
        LoadAnimDict(Config.Animations.Hostage.victimDict)
        
        -- Setup hostage state
        currentHostage = targetPed
        isHoldingHostage = true
        lastHostageTime = GetGameTimer()

        -- attachment configuration
        local offsetX = -0.3  -- Move hostage closer to player
        local offsetY = 0.1   -- Slight offset to the side
        local offsetZ = 0.0   -- Same height as player
        local rotX = 0.0      -- No pitch rotation
        local rotY = 0.0      -- No roll rotation
        local rotZ = 0.0      -- Face same direction as player
        
        AttachEntityToEntity(targetPed, ped, 11816, offsetX, offsetY, offsetZ, rotX, rotY, rotZ, false, false, false, false, 2, true)

        -- Play animations with movement flags
        TaskPlayAnim(targetPed, Config.Animations.Hostage.victimDict, Config.Animations.Hostage.victimAnim, 8.0, -8.0, -1, 51, 0, false, false, false)
        TaskPlayAnim(ped, Config.Animations.Hostage.dict, Config.Animations.Hostage.anim, 8.0, -8.0, -1, 51, 0, false, false, false)

        -- Dispatch
        exports['ps-dispatch']:CustomAlert({
            coords = GetEntityCoords(ped),
            message = Config.Dispatch.Hostage.description,
            dispatchCode = Config.Dispatch.Hostage.code,
            priority = 1,
            sprite = Config.Dispatch.Hostage.blipSprite,
            color = Config.Dispatch.Hostage.blipColor,
            scale = Config.Dispatch.Hostage.blipScale,
            length = Config.Dispatch.Hostage.blipLength,
        })

        -- Start animation maintenance thread
        CreateThread(function()
            while isHoldingHostage and DoesEntityExist(targetPed) do
                if not IsEntityPlayingAnim(targetPed, Config.Animations.Hostage.victimDict, Config.Animations.Hostage.victimAnim, 3) then
                    TaskPlayAnim(targetPed, Config.Animations.Hostage.victimDict, Config.Animations.Hostage.victimAnim, 8.0, -8.0, -1, 49, 0, false, false, false)
                end
                if not IsEntityPlayingAnim(ped, Config.Animations.Hostage.dict, Config.Animations.Hostage.anim, 3) then
                    TaskPlayAnim(ped, Config.Animations.Hostage.dict, Config.Animations.Hostage.anim, 8.0, -8.0, -1, 49, 0, false, false, false)
                end
                Wait(100)
            end
        end)
    end)
end

local function ReleaseHostage()
    if not currentHostage or not isHoldingHostage then return end
    if not DoesEntityExist(currentHostage) then return end

    local ped = PlayerPedId()
    local targetPed = currentHostage

    LoadAnimDict(Config.Animations.ReleaseHostage.dict)
    LoadAnimDict(Config.Animations.ReleaseHostage.victimDict)

    DetachEntity(targetPed, true, true)
    ClearPedTasksImmediately(targetPed)

    TaskPlayAnim(targetPed, Config.Animations.ReleaseHostage.victimDict, Config.Animations.ReleaseHostage.victimAnim, 8.0, -8.0, -1, 0, 0, false, false, false)
    TaskPlayAnim(ped, Config.Animations.ReleaseHostage.dict, Config.Animations.ReleaseHostage.anim, 8.0, -8.0, -1, 0, 0, false, false, false)

    Wait(1000)
    ClearPedTasks(ped)
    SetPedFleeAttributes(targetPed, 1, true)
    TaskSmartFleePed(targetPed, ped, 100.0, -1, true, true)

    isHoldingHostage = false
    currentHostage = nil
end

local function KillHostage()
    if not currentHostage or not isHoldingHostage then return end
    if not DoesEntityExist(currentHostage) then return end

    local ped = PlayerPedId()
    local targetPed = currentHostage
    
    local currentWeapon = GetSelectedPedWeapon(ped)
    local _, currentAmmo = GetAmmoInClip(ped, currentWeapon)

    LoadAnimDict(Config.Animations.KillHostage.dict)
    LoadAnimDict(Config.Animations.KillHostage.victimDict)

    DetachEntity(targetPed, true, true)
    ClearPedTasksImmediately(targetPed)

    TaskPlayAnim(targetPed, Config.Animations.KillHostage.victimDict, Config.Animations.KillHostage.victimAnim, 8.0, -8.0, -1, 0, 0, false, false, false)
    TaskPlayAnim(ped, Config.Animations.KillHostage.dict, Config.Animations.KillHostage.anim, 8.0, -8.0, -1, 0, 0, false, false, false)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "gunshot", 0.6)

    Wait(800)
    ClearPedTasks(ped)
    
    -- Improved death handling
    SetEntityHealth(targetPed, 0)
    SetPedToRagdoll(targetPed, 1000, 1000, 0, true, true, false)
    SetEntityAsMissionEntity(targetPed, true, true)
    SetPedDiesWhenInjured(targetPed, true)
    
    if currentAmmo > 0 then
        SetAmmoInClip(ped, currentWeapon, currentAmmo - 1)
    end

    isHoldingHostage = false
    currentHostage = nil
end

-- Event Handlers
RegisterNetEvent('rd-robhostage:client:rob')
AddEventHandler('rd-robhostage:client:rob', function(data)
    if data and data.entity then
        RobPerson(data.entity)
    end
end)

RegisterNetEvent('rd-robhostage:client:takeHostage')
AddEventHandler('rd-robhostage:client:takeHostage', function(data)
    if data and data.entity then
        StartHostage(data.entity)
    end
end)

-- Target Setup
exports['qb-target']:AddGlobalPed({
    options = {
        {
            type = "client",
            event = "rd-robhostage:client:rob",
            icon = "fas fa-mask",
            label = "Rob Person",
            canInteract = function(entity)
                if not entity then return false end
                if IsPedAPlayer(entity) then return false end
                if IsPedInAnyVehicle(entity, false) then return false end
                if IsPedDeadOrDying(entity) then return false end
                if not DoesEntityExist(entity) then return false end
                if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) > Config.MaxDistance then return false end
                
                local pedModel = GetEntityModel(entity)
                for _, blacklistedPed in ipairs(Config.BlacklistedPeds) do
                    if pedModel == GetHashKey(blacklistedPed) then
                        return false
                    end
                end
                
                return true
            end
        },
        {
            type = "client",
            event = "rd-robhostage:client:takeHostage",
            icon = "fas fa-user-shield",
            label = "Take Hostage",
            canInteract = function(entity)
                if not entity then return false end
                if IsPedAPlayer(entity) then return false end
                if IsPedInAnyVehicle(entity, false) then return false end
                if IsPedDeadOrDying(entity) then return false end
                if not DoesEntityExist(entity) then return false end
                if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) > Config.MaxDistance then return false end
                
                local pedModel = GetEntityModel(entity)
                for _, blacklistedPed in ipairs(Config.BlacklistedPeds) do
                    if pedModel == GetHashKey(blacklistedPed) then
                        return false
                    end
                end
                
                return true
            end
        }
    }
})

-- Keybinds
local killKeybind = lib.addKeybind({
    name = 'kill_hostage',
    description = 'Kill your hostage',
    defaultKey = Config.Keys.KillHostage,
    onReleased = function(self)
        if isHoldingHostage then
            KillHostage()
        end
    end
})

local releaseKeybind = lib.addKeybind({
    name = 'release_hostage',
    description = 'Release your hostage',
    defaultKey = Config.Keys.ReleaseHostage,
    onReleased = function(self)
        if isHoldingHostage then
            ReleaseHostage()
        end
    end
})


-- Display Controls
CreateThread(function()
    while true do
        Wait(0)
        if isHoldingHostage and currentHostage then
            -- Single background box for both options
            DrawRect(0.93, 0.52, 0.07, 0.07, 0, 0, 0, 180) -- Increased height to 0.07
            
            -- Kill hostage text (top)
            SetTextFont(4)
            SetTextScale(0.27, 0.27)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentString('[H] Kill hostage')
            EndTextCommandDisplayText(0.93, 0.495) -- Moved up
            
            -- Release hostage text (bottom)
            SetTextFont(4)
            SetTextScale(0.27, 0.27)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentString('[G] Release hostage')
            EndTextCommandDisplayText(0.93, 0.535) -- Moved up from 0.545 to 0.535
        end
    end
end)
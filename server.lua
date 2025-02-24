local QBCore = exports['qb-core']:GetCoreObject()

-- Cooldown tracking
local robCooldowns = {}
local hostageCooldowns = {}

-- Function to check cooldown
local function CheckCooldown(source, type)
    local currentTime = os.time()
    local cooldownTable = type == "rob" and robCooldowns or hostageCooldowns
    local cooldownTime = Config.Cooldowns[type:gsub("^%l", string.upper)] * 60 -- Convert minutes to seconds

    if cooldownTable[source] and currentTime - cooldownTable[source] < cooldownTime then
        return false
    end
    return true
end

-- Function to set cooldown
local function SetCooldown(source, type)
    local cooldownTable = type == "rob" and robCooldowns or hostageCooldowns
    cooldownTable[source] = os.time()
end

-- Function to give random items
local function GiveRandomItems(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local itemCount = math.random(1, 2)
    local addedItems = {}

    for i = 1, itemCount do
        local randomItem = Config.RobbableItems[math.random(#Config.RobbableItems)]
        local amount = 1

        -- Special handling for cash
        if randomItem.item == "cash" then
            amount = math.random(randomItem.minAmount or 100, randomItem.maxAmount or 500)
            Player.Functions.AddMoney('cash', amount)
            table.insert(addedItems, {item = "Cash", amount = amount})
        else
            -- Handle items based on inventory system
            if Config.UseQSInventory then
                exports['qs-inventory']:AddItem(source, randomItem.item, amount)
            else
                Player.Functions.AddItem(randomItem.item, amount)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[randomItem.item], 'add')
            end
            table.insert(addedItems, {item = randomItem.label, amount = amount})
        end
    end

    return addedItems
end

-- Callbacks
QBCore.Functions.CreateCallback('rd-robhostage:server:canDoAction', function(source, cb, actionType)
    if not CheckCooldown(source, actionType) then
        local cooldownTable = actionType == "rob" and robCooldowns or hostageCooldowns
        local timeLeft = math.ceil((Config.Cooldowns[actionType:gsub("^%l", string.upper)] * 60) - (os.time() - cooldownTable[source]))
        cb(false, "You must wait " .. timeLeft .. " seconds before doing this again.")
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rd-robhostage:server:getCopCount', function(source, cb)
    local cops = 0
    local players = QBCore.Functions.GetPlayers()
    for _, v in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player then
            if Config.PoliceJobs[Player.PlayerData.job.name] and Player.PlayerData.job.onduty then
                cops = cops + 1
            end
        end
    end
    cb(cops)
end)

-- Events
RegisterNetEvent('rd-robhostage:server:getRobbedItems', function()
    local source = source
    if not CheckCooldown(source, "rob") then return end

    local items = GiveRandomItems(source)
    if items then
        SetCooldown(source, "rob")
        local itemString = "Received: "
        for _, item in ipairs(items) do
            itemString = itemString .. item.amount .. "x " .. item.item .. ", "
        end
        TriggerClientEvent('QBCore:Notify', source, itemString:sub(1, -3), 'success')
    end
end)

RegisterNetEvent('rd-robhostage:server:startHostage', function(targetNetId)
    local source = source
    if not CheckCooldown(source, "hostage") then return end
    
    SetCooldown(source, "hostage")
    TriggerClientEvent('rd-robhostage:client:syncHostage', -1, targetNetId, source, true)
end)

RegisterNetEvent('rd-robhostage:server:releaseHostage', function(targetNetId)
    local source = source
    TriggerClientEvent('rd-robhostage:client:syncHostage', -1, targetNetId, source, false)
end)

RegisterNetEvent('rd-robhostage:server:killHostage', function(targetNetId)
    local source = source
    TriggerClientEvent('rd-robhostage:client:hostageKilled', -1, targetNetId)
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    local source = source
    robCooldowns[source] = nil
    hostageCooldowns[source] = nil
end)


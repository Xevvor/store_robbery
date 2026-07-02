---@diagnostic disable: undefined-global

local robberySessions = {}
local activeRobbers = {}
local nextRobberyAt = {}

local function getShopById(shopId)
    for i = 1, #Config.Shops do
        if Config.Shops[i].id == shopId then
            return Config.Shops[i]
        end
    end
end

local function playerHasAllowedPistol(playerId)
    local ped = GetPlayerPed(playerId)

    if ped <= 0 then
        return false
    end

    local currentWeapon = GetSelectedPedWeapon(ped)

    for i = 1, #Config.AllowedPistols do
        if currentWeapon == Config.AllowedPistols[i] then
            return true
        end
    end

    return false
end

local function isPlayerNearShop(playerId, shop, maxDistance)
    local ped = GetPlayerPed(playerId)

    if ped <= 0 then
        return false
    end

    local playerCoords = GetEntityCoords(ped)
    return #(playerCoords - vec3(shop.coords.x, shop.coords.y, shop.coords.z)) <= maxDistance
end

local function clearRobberySession(playerId)
    local session = robberySessions[playerId]
    robberySessions[playerId] = nil

    if session and activeRobbers[session.shopId] == playerId then
        activeRobbers[session.shopId] = nil
    end
end

local function getCooldownMessage(remainingMs)
    local totalSeconds = math.max(1, math.ceil(remainingMs / 1000))
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60

    if minutes > 0 then
        return ('Come back in %dm %02ds.'):format(minutes, seconds)
    end

    return ('Come back in %ds.'):format(seconds)
end

lib.callback.register('store_robbery:canStartRobbery', function(source, shopId)
    local now = GetGameTimer()
    local shop = getShopById(shopId)

    if not shop then
        return false, 'This shop is not configured.'
    end

    local session = robberySessions[source]

    if session and session.shopId ~= shopId then
        return false, 'Finish or cancel your current robbery first.'
    end

    if not playerHasAllowedPistol(source) then
        return false, 'You need to be holding a pistol to start the robbery.'
    end

    if not isPlayerNearShop(source, shop, Config.Validation.maxStartDistance) then
        return false, 'Move closer to the clerk to start the robbery.'
    end

    if activeRobbers[shopId] and activeRobbers[shopId] ~= source then
        return false, 'Someone is already robbing this shop.'
    end

    if now < (nextRobberyAt[shopId] or 0) then
        return false, ('This shop was hit recently. %s'):format(getCooldownMessage((nextRobberyAt[shopId] or 0) - now))
    end

    return true
end)

RegisterNetEvent('store_robbery:startRobbery', function(shopId)
    local source = source
    local shop = getShopById(shopId)

    if not shop then
        return
    end

    local session = robberySessions[source]

    if session and session.shopId ~= shopId then
        return
    end

    if not playerHasAllowedPistol(source) then
        return
    end

    if not isPlayerNearShop(source, shop, Config.Validation.maxStartDistance) then
        return
    end

    if activeRobbers[shopId] and activeRobbers[shopId] ~= source then
        return
    end

    if GetGameTimer() < (nextRobberyAt[shopId] or 0) then
        return
    end

    robberySessions[source] = {
        startedAt = GetGameTimer(),
        shopId = shopId
    }

    activeRobbers[shopId] = source
end)

RegisterNetEvent('store_robbery:cancelRobbery', function()
    clearRobberySession(source)
end)

RegisterNetEvent('store_robbery:completeRobbery', function(shopId)
    local source = source
    local session = robberySessions[source]
    local shop = getShopById(shopId)

    if not session or not shop or session.shopId ~= shopId then
        return
    end

    local elapsed = GetGameTimer() - session.startedAt
    local ped = GetPlayerPed(source)

    if ped <= 0 then
        clearRobberySession(source)
        return
    end

    local playerCoords = GetEntityCoords(ped)

    if #(playerCoords - vec3(shop.coords.x, shop.coords.y, shop.coords.z)) > Config.Validation.maxRewardDistance then
        clearRobberySession(source)
        return
    end

    if elapsed < ((Config.Durations.threatening + Config.Durations.stealing) - Config.Validation.completionLeeway) then
        clearRobberySession(source)
        return
    end

    local payout = math.random(Config.Rewards.minPayout, Config.Rewards.maxPayout)
    local added = exports.ox_inventory:AddItem(source, Config.Rewards.item, payout)

    clearRobberySession(source)

    if not added then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Store Robbery',
            description = 'You could not carry the stolen cash.',
            type = 'error'
        })
        return
    end

    nextRobberyAt[shopId] = GetGameTimer() + Config.Cooldown

    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Store Robbery',
        description = ('You stole $%s.'):format(lib.math.groupdigits(payout)),
        type = 'success'
    })
end)

AddEventHandler('playerDropped', function()
    clearRobberySession(source)
end)

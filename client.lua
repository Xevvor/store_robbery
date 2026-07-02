---@diagnostic disable: undefined-global

local robberyActive = false
local shopkeepers = {}

local function loadAnimDict(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

local function playEmote(name)
    exports['rpemotes-reborn']:EmoteCommandStart(name)
end

local function playClerkReaction(npcEntity)
    if not npcEntity or npcEntity == 0 or not DoesEntityExist(npcEntity) then
        return
    end

    FreezeEntityPosition(npcEntity, true)
    local reaction = Config.ClerkReaction.mode

    if reaction == 'handsup' then
        TaskHandsUp(npcEntity, Config.ClerkReaction.handsupDuration, PlayerPedId(), -1, true)
        return
    end

    local anim = reaction == 'panic' and Config.ClerkReaction.panicAnim or Config.ClerkReaction.cowerAnim
    loadAnimDict(anim.dict)
    TaskPlayAnim(npcEntity, anim.dict, anim.clip, 8.0, -8.0, -1, anim.flag, 0.0, false, false, false)
end

local function resetClerkReaction(npcEntity, shop)
    if not npcEntity or npcEntity == 0 or not DoesEntityExist(npcEntity) then
        return
    end

    ClearPedTasks(npcEntity)

    if shop.spawnCoords then
        SetEntityCoordsNoOffset(npcEntity, shop.spawnCoords.x, shop.spawnCoords.y, shop.spawnCoords.z, false, false, false)
        SetEntityHeading(npcEntity, shop.spawnHeading or shop.coords.w)
    end

    SetBlockingOfNonTemporaryEvents(npcEntity, true)
    TaskStandStill(npcEntity, -1)
    FreezeEntityPosition(npcEntity, true)
end

local function showPhaseProgress(label, duration, icon)
    local startTime = GetGameTimer()
    local isTracking = true

    CreateThread(function()
        local lastPercent = -1

        while isTracking do
            local elapsed = GetGameTimer() - startTime
            local percent = math.min(100, math.floor((elapsed / duration) * 100))

            if percent ~= lastPercent then
                lib.showTextUI(('%s %d%%'):format(label, percent), {
                    position = 'bottom-center',
                    icon = icon,
                    iconColor = '#ff5a36',
                    style = {
                        borderRadius = '10px',
                        backgroundColor = '#121821',
                        color = '#f5f7fb'
                    }
                })
                lastPercent = percent
            end

            Wait(100)
        end
    end)

    local completed = lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        allowRagdoll = false,
        allowSwimming = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        }
    })

    isTracking = false
    lib.hideTextUI()

    return completed
end

local function showThreateningProgress()
    return showPhaseProgress('Threatening', Config.Durations.threatening, 'gun')
end

local function showStealingProgress()
    return showPhaseProgress('Stealing', Config.Durations.stealing, 'mask')
end

local function playerHasAnyWeapon()
    local playerPed = PlayerPedId()

    for i = 1, #Config.AllowedPistols do
        if HasPedGotWeapon(playerPed, Config.AllowedPistols[i], false) then
            return true
        end
    end

    return false
end

local function interactWithShopkeep(npcEntity, shop)
    if robberyActive or lib.progressActive() then
        return
    end

    if not playerHasAnyWeapon() then
        lib.notify({
            title = 'Store Robbery',
            description = 'You need a pistol to threaten the clerk.',
            type = 'error'
        })
        return
    end

    local canStart, reason = lib.callback.await('store_robbery:canStartRobbery', false, shop.id)

    if not canStart then
        lib.notify({
            title = 'Store Robbery',
            description = reason or 'You cannot rob this shop right now.',
            type = 'error'
        })
        return
    end

    robberyActive = true
    TriggerServerEvent('store_robbery:startRobbery', shop.id)
    playEmote('gunpoint')
    playClerkReaction(npcEntity)

    local threatened = showThreateningProgress()

    exports['rpemotes-reborn']:EmoteCancel()

    if not threatened then
        TriggerServerEvent('store_robbery:cancelRobbery')
        ClearPedTasks(PlayerPedId())
        resetClerkReaction(npcEntity, shop)
        robberyActive = false
        return
    end

    playEmote('mechanic')

    local success = showStealingProgress()

    exports['rpemotes-reborn']:EmoteCancel()
    ClearPedTasks(PlayerPedId())
    resetClerkReaction(npcEntity, shop)
    robberyActive = false

    if success then
        TriggerServerEvent('store_robbery:completeRobbery', shop.id)
        return
    end

    TriggerServerEvent('store_robbery:cancelRobbery')
end

CreateThread(function()
    RequestModel(Config.DefaultClerkModel)

    while not HasModelLoaded(Config.DefaultClerkModel) do
        Wait(1)
    end

    for i = 1, #Config.Shops do
        local shop = Config.Shops[i]
        local ped = CreatePed(4, Config.DefaultClerkModel, shop.coords.x, shop.coords.y, shop.coords.z, shop.coords.w, false, true)

        shopkeepers[shop.id] = ped
        shop.spawnCoords = GetEntityCoords(ped)
        shop.spawnHeading = GetEntityHeading(ped)

        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanPlayAmbientAnims(ped, false)
        SetPedCanRagdoll(ped, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        TaskStandStill(ped, -1)

        exports.ox_target:addLocalEntity(ped, {
            {
                name = ('shopkeep_interaction_%s'):format(shop.id),
                icon = 'fa-solid fa-comments',
                label = 'Start Robbery',
                distance = shop.targetDistance or Config.DefaultTargetDistance,
                onSelect = function(data)
                    interactWithShopkeep(data.entity, shop)
                end
            }
        })
    end

    SetModelAsNoLongerNeeded(Config.DefaultClerkModel)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for shopId, ped in pairs(shopkeepers) do
        if DoesEntityExist(ped) then
            exports.ox_target:removeLocalEntity(ped, ('shopkeep_interaction_%s'):format(shopId))
            DeleteEntity(ped)
        end
    end
end)

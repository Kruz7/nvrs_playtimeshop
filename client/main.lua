local QBCore = exports["qb-core"]:GetCoreObject()

local PlayerData = {}
local playEndAt = 0

local function setPlayEndFromRemaining(seconds)
    local s = tonumber(seconds) or 0
    if s < 0 then
        s = 0
    end
    playEndAt = GetGameTimer() + (s * 1000)
end

local function syncPlaytime()
    QBCore.Functions.TriggerCallback("nvrs-playtimeshop:getPlaytimeSync", function(sec)
        setPlayEndFromRemaining(sec)
    end)
end

CreateThread(function()
    if NCHub.Framework == "oldqb" then
        while QBCore == nil do
            TriggerEvent("QBCore:GetObject", function(obj)
                QBCore = obj
            end)
            Wait(200)
        end
    elseif NCHub.Framework == "qb" then
        while QBCore == nil do
            Wait(200)
        end
    end
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(1500)
    syncPlaytime()
    SendNUIMessage({
        type = "translate",
        translate = NCHub.Language,
        locale = NCHub.Locale,
    })
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(1000)
    syncPlaytime()
    SendNUIMessage({
        type = "translate",
        translate = NCHub.Language,
        locale = NCHub.Locale,
    })
end)

RegisterCommand(NCHub.OpenCommand, function()
    openMenu()
end)

local openMenuSpamProtect = 0
function openMenu()
    if openMenuSpamProtect >= GetGameTimer() then
        return
    end
    openMenuSpamProtect = GetGameTimer() + 1500
    QBCore.Functions.TriggerCallback("nvrs-playtimeshop:getPlayerDetails", function(result)
        if not result then
            return
        end
        PlayerData = QBCore.Functions.GetPlayerData()
        if not PlayerData or not PlayerData.charinfo then
            return
        end
        local resName = GetCurrentResourceName()
        local remainingStr = disp_time(result.remainingSeconds or 0)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openui",
            resourceName = resName,
            coin = result.coin,
            categories = NCHub.Categories,
            items = NCHub.Items,
            steamAvatarUrl = result.steamAvatarUrl or "./images/pp.png",
            firstname = result.firstname,
            lastname = result.lastname,
            remaining = remainingStr,
            remainingSeconds = result.remainingSeconds,
            coinReward = result.coinReward,
            coinRewardBonus = result.coinRewardBonus,
            coinList = NCHub.CoinList,
            topPlayers = result.topPlayers,
        })
    end)
end

function disp_time(time)
    time = tonumber(time) or 0
    local days = math.floor(time / 86400)
    local remaining = time % 86400
    local hours = math.floor(remaining / 3600)
    remaining = remaining % 3600
    local minutes = math.floor(remaining / 60)
    remaining = remaining % 60
    local seconds = remaining
    if hours < 10 then
        hours = "0" .. tostring(hours)
    end
    if minutes < 10 then
        minutes = "0" .. tostring(minutes)
    end
    if seconds < 10 then
        seconds = "0" .. tostring(seconds)
    end
    if days > 0 then
        return days .. "d " .. hours .. "h " .. minutes .. "m"
    end
    if hours ~= "00" then
        return hours .. "h " .. minutes .. "m"
    end
    return minutes .. "m " .. seconds .. "s"
end

CreateThread(function()
    while true do
        Wait(1000)
        if playEndAt > 0 and GetGameTimer() >= playEndAt then
            local blockUntil = GetGameTimer() + 8000
            playEndAt = blockUntil
            QBCore.Functions.TriggerCallback("nvrs-playtimeshop:claimPlaytimeReward", function(_, remaining, __)
                if type(remaining) == "number" then
                    setPlayEndFromRemaining(remaining)
                else
                    syncPlaytime()
                end
            end)
        end
    end
end)

local buyItemSpamProtect = 0
RegisterNUICallback("buyItem", function(data, cb)
    if buyItemSpamProtect >= GetGameTimer() then
        cb(false)
        return
    end
    buyItemSpamProtect = GetGameTimer() + 1500
    QBCore.Functions.TriggerCallback("nvrs-playtimeshop:buyItem", function(result)
        cb(result)
    end, data)
end)

local sendInputProtect = 0
RegisterNUICallback("sendInput", function(data, cb)
    if sendInputProtect >= GetGameTimer() then
        cb(false)
        return
    end
    sendInputProtect = GetGameTimer() + 1500
    QBCore.Functions.TriggerCallback("nvrs-playtimeshop:sendInput", function(result)
        cb(result)
    end, data)
end)

RegisterNUICallback("closeMenu", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

local QBCore = exports["qb-core"]:GetCoreObject()

local topPlayers = {}
local purchaseCooldown = {}
local redeemCooldown = {}
local claimCooldown = {}
local lastPurchase = {}
local tebexLock = false

local function refreshTopPlayers()
    local rows = MySQL.query.await("SELECT firstName, lastName, coin FROM nvrs_playtimeshop ORDER BY coin DESC LIMIT 6", {})
    topPlayers = rows or {}
end

CreateThread(function()
    refreshTopPlayers()
    while true do
        Wait(300000)
        refreshTopPlayers()
    end
end)

local function ensureShopRow(src)
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then
        return nil
    end
    local citizenId = xPlayer.PlayerData.citizenid
    local row = MySQL.single.await("SELECT * FROM nvrs_playtimeshop WHERE citizenid = ?", { citizenId })
    local fn = xPlayer.PlayerData.charinfo.firstname
    local ln = xPlayer.PlayerData.charinfo.lastname
    local offset = NCHub.NeededPlayTime * 60
    if not row then
        local nextAt = os.time() + offset
        MySQL.insert.await(
            "INSERT INTO nvrs_playtimeshop (citizenid, coin, firstName, lastName, next_playtime_reward_at) VALUES (?, ?, ?, ?, ?)",
            { citizenId, 0, fn, ln, nextAt }
        )
        return {
            coin = 0,
            next_playtime_reward_at = nextAt,
            citizenid = citizenId,
            firstName = fn,
            lastName = ln,
        }
    end
    local n = tonumber(row.next_playtime_reward_at)
    if not n or n == 0 then
        local nextAt = os.time() + offset
        MySQL.update.await("UPDATE nvrs_playtimeshop SET next_playtime_reward_at = ?, firstName = ?, lastName = ? WHERE citizenid = ?", {
            nextAt,
            fn,
            ln,
            citizenId,
        })
        row.next_playtime_reward_at = nextAt
    else
        MySQL.update.await("UPDATE nvrs_playtimeshop SET firstName = ?, lastName = ? WHERE citizenid = ?", { fn, ln, citizenId })
    end
    row.coin = tonumber(row.coin) or 0
    return row
end

local function steamAvatarAsync(src, callback)
    local steam64
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(id, 1, 6) == "steam:" then
            steam64 = tonumber(string.sub(id, 7), 16)
            break
        end
    end
    local defaultImg = "./images/pp.png"
    if not steam64 or not steamApiKey or steamApiKey == "" then
        callback(defaultImg)
        return
    end
    local url = ("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s"):format(steamApiKey, steam64)
    PerformHttpRequest(url, function(status, body)
        local img = defaultImg
        if status == 200 and body then
            local ok, data = pcall(json.decode, body)
            if ok and data and data.response and data.response.players and data.response.players[1] and data.response.players[1].avatarfull then
                img = data.response.players[1].avatarfull
            end
        end
        callback(img)
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

local function buildDetailsPayload(row, src)
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local nextAt = tonumber(row.next_playtime_reward_at) or 0
    local remainingSeconds = math.max(0, nextAt - os.time())
    return {
        coin = tonumber(row.coin) or 0,
        topPlayers = topPlayers,
        firstname = xPlayer.PlayerData.charinfo.firstname,
        lastname = xPlayer.PlayerData.charinfo.lastname,
        remainingSeconds = remainingSeconds,
        coinReward = NCHub.RewardCoin,
        coinRewardBonus = math.floor(NCHub.RewardCoin * (NCHub.BonusZone.multiplier or 2)),
    }
end

QBCore.Functions.CreateCallback("nvrs-playtimeshop:getPlayerDetails", function(source, cb)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then
        cb(nil)
        return
    end
    local row = ensureShopRow(src)
    if not row then
        cb(nil)
        return
    end
    local responded = false
    local function finish(avatarUrl)
        if responded then
            return
        end
        responded = true
        local payload = buildDetailsPayload(row, src)
        payload.steamAvatarUrl = avatarUrl
        cb(payload)
    end
    steamAvatarAsync(src, function(avatarUrl)
        finish(avatarUrl)
    end)
    Citizen.SetTimeout(10000, function()
        finish("./images/pp.png")
    end)
end)

QBCore.Functions.CreateCallback("nvrs-playtimeshop:getPlaytimeSync", function(source, cb)
    local src = source
    local row = ensureShopRow(src)
    if not row then
        cb(NCHub.NeededPlayTime * 60)
        return
    end
    local nextAt = tonumber(row.next_playtime_reward_at) or 0
    cb(math.max(0, nextAt - os.time()))
end)

QBCore.Functions.CreateCallback("nvrs-playtimeshop:claimPlaytimeReward", function(source, cb)
    local src = source
    local now = os.time()
    if claimCooldown[src] and (now - claimCooldown[src]) < 3 then
        local row = ensureShopRow(src)
        if row then
            local nextAt = tonumber(row.next_playtime_reward_at) or 0
            cb(false, math.max(0, nextAt - os.time()), 0)
        else
            cb(false, NCHub.NeededPlayTime * 60, 0)
        end
        return
    end
    claimCooldown[src] = now

    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then
        cb(false, NCHub.NeededPlayTime * 60, 0)
        return
    end

    local row = ensureShopRow(src)
    if not row then
        cb(false, NCHub.NeededPlayTime * 60, 0)
        return
    end

    local citizenId = xPlayer.PlayerData.citizenid
    local nextAt = tonumber(row.next_playtime_reward_at) or 0
    if now < nextAt - 1 then
        cb(false, math.max(0, nextAt - now), 0)
        return
    end

    local ped = GetPlayerPed(src)
    local bonus = false
    if ped and ped ~= 0 then
        local c = GetEntityCoords(ped)
        local dz = NCHub.BonusZone
        if dz and dz.coords and #(c - dz.coords) <= (dz.radius or 50.0) then
            bonus = true
        end
    end

    local mult = bonus and (NCHub.BonusZone.multiplier or 2) or 1
    local add = math.floor(NCHub.RewardCoin * mult)
    local newNext = now + (NCHub.NeededPlayTime * 60)

    MySQL.update.await(
        "UPDATE nvrs_playtimeshop SET coin = coin + ?, next_playtime_reward_at = ? WHERE citizenid = ?",
        { add, newNext, citizenId }
    )

    local remaining = math.max(0, newNext - os.time())
    cb(true, remaining, add)
end)

QBCore.Functions.CreateCallback("nvrs-playtimeshop:buyItem", function(source, cb, data)
    local src = source
    if GetPlayerPing(src) > (NCHub.MaxPingForPurchase or 400) then
        TriggerClientEvent("QBCore:Notify", src, "Ping too high for purchase.", "error")
        cb(false)
        return
    end

    local now = os.time()
    if purchaseCooldown[src] and (now - purchaseCooldown[src]) < 5 then
        cb(false)
        return
    end
    purchaseCooldown[src] = now

    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then
        cb(false)
        return
    end

    local citizenId = xPlayer.PlayerData.citizenid
    local jsItem = data and data.itemInfo
    if type(jsItem) ~= "table" or not jsItem.id then
        cb(false)
        return
    end

    local selectedItem
    for _, v in pairs(NCHub.Items) do
        if v.id == jsItem.id then
            selectedItem = v
            break
        end
    end

    if not selectedItem then
        NvrsBanPlayer(src, "Invalid playtime shop purchase attempt.")
        NvrsLog("playtimeshoplog2", "Invalid item", "red", ("Invalid purchase cid=%s itemId=%s"):format(citizenId, tostring(jsItem.id)))
        cb(false)
        return
    end

    if selectedItem.count ~= tonumber(jsItem.count) or selectedItem.itemName ~= jsItem.itemName or selectedItem.itemType ~= jsItem.itemType then
        NvrsBanPlayer(src, "Playtime shop payload mismatch.")
        NvrsLog("playtimeshoplog2", "Payload mismatch", "red", ("cid=%s id=%s"):format(citizenId, tostring(jsItem.id)))
        cb(false)
        return
    end

    local row = MySQL.single.await("SELECT coin FROM nvrs_playtimeshop WHERE citizenid = ?", { citizenId })
    if not row then
        cb(false)
        return
    end

    local balance = tonumber(row.coin) or 0
    local price = tonumber(selectedItem.price) or 0
    if balance < price then
        cb(false)
        return
    end

    if lastPurchase[src] and lastPurchase[src].time and (now - lastPurchase[src].time) < 20 then
        if
            (lastPurchase[src].itemType == "vehicle" or lastPurchase[src].itemType == "weapon")
            and (selectedItem.itemType == "vehicle" or selectedItem.itemType == "weapon")
        then
            NvrsLog(
                "playtimeshoplog3",
                "Rapid weapon/vehicle",
                "red",
                ("Player %s cid=%s"):format(GetPlayerName(src) or "?", citizenId)
            )
        end
    end
    lastPurchase[src] = { time = now, itemType = selectedItem.itemType }

    local affected = MySQL.update.await(
        "UPDATE nvrs_playtimeshop SET coin = coin - ? WHERE citizenid = ? AND coin >= ?",
        { price, citizenId, price }
    )
    if affected == false or affected == nil or (type(affected) == "number" and affected < 1) then
        cb(false)
        return
    end

    local myItem = selectedItem.itemName
    local count = selectedItem.count
    local itemType = selectedItem.itemType

    if itemType == "item" then
        xPlayer.Functions.AddItem(myItem, count)
    elseif itemType == "weapon" then
        for _ = 1, count do
            xPlayer.Functions.AddItem(myItem, 1)
        end
    elseif itemType == "vehicle" then
        for _ = 1, count do
            local plate = GeneratePlate()
            local license = xPlayer.PlayerData.license
            local vhash = GetHashKey(myItem)
            MySQL.insert.await(
                "INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                { license, citizenId, myItem, vhash, "{}", plate, NCHub.DefaultGarage, 1 }
            )
        end
    elseif itemType == "money" then
        xPlayer.Functions.AddMoney("cash", count)
    end

    local updated = MySQL.single.await("SELECT coin FROM nvrs_playtimeshop WHERE citizenid = ?", { citizenId })
    local remainingCoin = updated and tonumber(updated.coin) or 0
    NvrsLog(
        "playtimeshoplog2",
        "Purchase",
        "green",
        ("%s (%s) bought %s x%s for %s coins, balance %s"):format(
            GetPlayerName(src) or "?",
            citizenId,
            myItem,
            tostring(count),
            tostring(price),
            tostring(remainingCoin)
        )
    )

    cb(true)
end)

local function sanitizeCode(str)
    if type(str) ~= "string" then
        return nil
    end
    str = str:gsub("%s+", "")
    if #str < 3 or #str > 64 then
        return nil
    end
    if not str:match("^[%w%-]+$") then
        return nil
    end
    return str
end

QBCore.Functions.CreateCallback("nvrs-playtimeshop:sendInput", function(source, cb, data)
    local src = source
    local now = os.time()
    if redeemCooldown[src] and (now - redeemCooldown[src]) < 5 then
        cb(false)
        return
    end
    redeemCooldown[src] = now

    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then
        cb(false)
        return
    end

    local inputData = sanitizeCode(data and data.input)
    if not inputData then
        cb(false)
        return
    end

    local citizenId = xPlayer.PlayerData.citizenid
    local result = MySQL.single.await("SELECT credit FROM nvrs_playtimeshop_codes WHERE code = ?", { inputData })
    if not result then
        cb(false)
        return
    end

    local credit = tonumber(result.credit)
    if not credit or credit < 1 or credit > 1000000 then
        cb(false)
        return
    end

    MySQL.update.await("DELETE FROM nvrs_playtimeshop_codes WHERE code = ?", { inputData })
    MySQL.update.await("UPDATE nvrs_playtimeshop SET coin = coin + ? WHERE citizenid = ?", { credit, citizenId })

    NvrsLog("playtimeshoplog", "Redeem", "green", ("%s redeemed code, +%s coins"):format(GetPlayerName(src) or "?", tostring(credit)))
    cb(credit)
end)

RegisterCommand("purchase_playtime_credit", function(source, args)
    local src = source
    if src ~= 0 then
        NvrsBanPlayer(src, "Console-only Tebex command.")
        return
    end
    if not args[1] then
        return
    end
    local ok, dec = pcall(json.decode, args[1])
    if not ok or type(dec) ~= "table" or not dec.transid or not dec.credit then
        return
    end
    local tbxid = tostring(dec.transid)
    local credit = tonumber(dec.credit)
    if not credit or credit < 1 or credit > 1000000 or #tbxid > 128 then
        return
    end
    while tebexLock do
        Wait(100)
    end
    tebexLock = true
    local exists = MySQL.single.await("SELECT 1 AS ok FROM nvrs_playtimeshop_codes WHERE code = ? LIMIT 1", { tbxid })
    if not exists then
        MySQL.insert.await("INSERT INTO nvrs_playtimeshop_codes (code, credit) VALUES (?, ?)", { tbxid, credit })
        SendToDiscord("Tebex code", ("Code `%s` credit `%s` stored."):format(tbxid, credit), 3066993)
    end
    tebexLock = false
end, true)

function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    plate = plate:upper()
    local exists = MySQL.single.await("SELECT plate FROM player_vehicles WHERE plate = ?", { plate })
    if exists then
        return GeneratePlate()
    end
    return plate
end

local DISCORD_NAME = "nvrs_playtimeshop"
local DISCORD_IMAGE = ""
function SendToDiscord(name, message, color)
    if not Discord_Webhook or Discord_Webhook == "" or Discord_Webhook == "CHANGE_WEBHOOK" then
        return
    end
    local embed = {
        {
            ["color"] = color or 3066993,
            ["title"] = "**" .. tostring(name) .. "**",
            ["description"] = tostring(message),
            ["footer"] = { ["text"] = "nvrs_playtimeshop" },
        },
    }
    PerformHttpRequest(
        Discord_Webhook,
        function() end,
        "POST",
        json.encode({ username = DISCORD_NAME, embeds = embed, avatar_url = DISCORD_IMAGE ~= "" and DISCORD_IMAGE or nil }),
        { ["Content-Type"] = "application/json" }
    )
end

AddEventHandler("playerDropped", function()
    local src = source
    purchaseCooldown[src] = nil
    redeemCooldown[src] = nil
    claimCooldown[src] = nil
    lastPurchase[src] = nil
end)

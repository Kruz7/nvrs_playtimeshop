NCHub = {}

NCHub.Framework = "qb"
NCHub.Mysql = "oxmysql"
NCHub.OpenCommand = "playtimeShop"
NCHub.DefaultGarage = "pillboxgarage"
NCHub.RewardCoin = 8
NCHub.NeededPlayTime = 60
NCHub.Locale = "en"
NCHub.MaxPingForPurchase = 400
NCHub.UseRiaLogs = false
NCHub.BanResource = nil
NCHub.BanExport = nil

NCHub.BonusZone = {
    coords = vector3(1828.88, -1206.72, -13.02),
    radius = 50.0,
    multiplier = 2,
}

NCHub.Locales = {
    en = {
        title1 = "NVRS",
        title2 = "Playtime",
        coin = "COIN",
        nextReward = "TIME UNTIL NEXT COIN REWARD",
        exit = "Exit",
        reward = "REWARD",
        title3 = "TOP",
        title4 = "PLAYERS",
        title5 = "PLAYTIME",
        title6 = "SHOP",
        cancel = "CANCEL",
        buy = "BUY",
        accept = "ACCEPT",
        realCurrency = "$",
        nextPage = "NEXT PAGE",
        previousPage = "PREVIOUS PAGE",
        succesfully = "SUCCESS",
        purchased = "PURCHASED",
        invalidCode = "Invalid code.",
        thxForPurch = "Thank you for your purchase!",
        top = "TOP",
        youDntHvEngMoney = "Not enough coins.",
        text6 = "6",
        redeemPlaceholder = "Enter redeem code...",
        purchaseLineStart = "FOR ",
        purchaseLineEnd = ", DO YOU APPROVE<br/>THE PURCHASE?",
        weeklyPlayers = "PLAYERS",
        notifyPurchaseOk = "Purchase completed.",
    },
    tr = {
        title1 = "NVRS",
        title2 = "Oyun Saati",
        coin = "JETON",
        nextReward = "SONRAKİ ÖDÜL İÇİN KALAN SÜRE",
        exit = "Çıkış",
        reward = "ÖDÜL",
        title3 = "EN İYİ",
        title4 = "OYUNCULAR",
        title5 = "PLAYTIME",
        title6 = "MAĞAZA",
        cancel = "İPTAL",
        buy = "SATIN AL",
        accept = "ONAYLA",
        realCurrency = "₺",
        nextPage = "SONRAKİ SAYFA",
        previousPage = "ÖNCEKİ SAYFA",
        succesfully = "BAŞARILI",
        purchased = "SATIN ALINDI",
        invalidCode = "Geçersiz kod.",
        thxForPurch = "Satın aldığınız için teşekkürler!",
        top = "TOP",
        youDntHvEngMoney = "Yeterli jetonunuz yok.",
        text6 = "6",
        redeemPlaceholder = "Kodu girin...",
        purchaseLineStart = "",
        purchaseLineEnd = " için satın alımı onaylıyor musunuz?",
        weeklyPlayers = "OYUNCULAR",
        notifyPurchaseOk = "Satın alma tamamlandı.",
    },
}

NCHub.Language = {}
do
    local loc = NCHub.Locales[NCHub.Locale] or NCHub.Locales.en
    for k, v in pairs(loc) do
        NCHub.Language[k] = v
    end
end

NCHub.Categories = {
    { category = "items", icon = "fa-solid fa-cookie-bite", items = {} },
    { category = "weapons", icon = "fa-solid fa-gun", items = {} },
    { category = "vehicles", icon = "fa-solid fa-car", items = {} },
}

NCHub.Items = {
    { id = 1, itemName = "weapon_dp9", label = "Diamond DB9", price = 570, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_dp9.png" },
    { id = 2, itemName = "weapon_p226", label = "Sig Sauer P226", price = 450, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_p226.png" },
    { id = 3, itemName = "weapon_g17", label = "Glock 17 A", price = 640, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_g17.png" },
    { id = 4, itemName = "weapon_g19", label = "Glock 19", price = 780, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_g19.png" },
    { id = 5, itemName = "weapon_switchblade", label = "Switchblade", price = 2000, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_switchblade.png" },
    { id = 6, itemName = "weapon_bat", label = "Bat", price = 130, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_bat.png" },
    { id = 7, itemName = "weapon_bottle", label = "Broken bottle", price = 130, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_bottle.png" },
    { id = 8, itemName = "weapon_poolcue", label = "Pool cue", price = 210, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_poolcue.png" },
    { id = 9, itemName = "pistol_extendedclip", label = "Pistol extended mag", price = 410, count = 1, itemType = "weapon", category = "weapons", image = "./images/pistol_extendedclip.png" },
    { id = 12, itemName = "pistol_suppressor", label = "Pistol suppressor", price = 410, count = 1, itemType = "weapon", category = "weapons", image = "./images/pistol_suppressor.png" },
    { id = 13, itemName = "weapon_crowbar", label = "Crowbar", price = 200, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_crowbar.png" },
    { id = 14, itemName = "weapon_knife", label = "Knife", price = 260, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_knife.png" },
    { id = 15, itemName = "weapon_knuckle", label = "Knuckle", price = 200, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_knuckle.png" },
    { id = 16, itemName = "weapon_assaultrifle2", label = "AK-47", price = 10000, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_assaultrifle.png" },
    { id = 17, itemName = "tamirkiti", label = "Repair kit", price = 25, count = 1, itemType = "item", category = "items", image = "./images/advancedkit.png" },
    { id = 18, itemName = "lockpick", label = "Lockpick", price = 45, count = 1, itemType = "item", category = "items", image = "./images/lockpick.png" },
    { id = 19, itemName = "heavyarmor", label = "Armor", price = 35, count = 1, itemType = "item", category = "items", image = "./images/armor.png" },
    { id = 20, itemName = "bandage", label = "Bandage", price = 4, count = 1, itemType = "item", category = "items", image = "./images/firstaid.png" },
    { id = 21, itemName = "lockpick", label = "Lockpick (alt)", price = 75, count = 1, itemType = "item", category = "items", image = "./images/lockpick.png" },
    { id = 22, itemName = "package-weed-max-ql", label = "Weed pack", price = 45, count = 35, itemType = "item", category = "items", image = "./images/package-weed-max-ql.png" },
    { id = 23, itemName = "package-opium-max-ql", label = "Opium pack", price = 45, count = 35, itemType = "item", category = "items", image = "./images/package-opium-max-ql.png" },
    { id = 24, itemName = "package-meth-max-ql", label = "Meth pack", price = 50, count = 35, itemType = "item", category = "items", image = "./images/package-meth-max-ql.png" },
    { id = 25, itemName = "ammo-9", label = "Pistol ammo", price = 80, count = 3, itemType = "item", category = "items", image = "./images/pistol_ammo.png" },
    { id = 26, itemName = "radio", label = "Radio", price = 10, count = 1, itemType = "item", category = "items", image = "./images/radio.png" },
    { id = 27, itemName = "zentorno", label = "Zentorno", price = 600, count = 1, itemType = "vehicle", category = "vehicles", image = "./images/zentorno.png" },
    { id = 28, itemName = "kuruma", label = "Kuruma", price = 450, count = 1, itemType = "vehicle", category = "vehicles", image = "./images/kuruma.png" },
    { id = 29, itemName = "69charger", label = "1969 Charger", price = 1380, count = 1, itemType = "vehicle", category = "vehicles", image = "./images/69charger.png" },
    { id = 32, itemName = "rmodmustang", label = "Ford Mustang GT", price = 2000, count = 1, itemType = "vehicle", category = "vehicles", image = "./images/rmodmustang.png" },
    { id = 34, itemName = "nissantitan17", label = "Nissan Titan", price = 3500, count = 1, itemType = "vehicle", category = "vehicles", image = "./images/nissantitan17.png" },
}

NCHub.CoinList = {}

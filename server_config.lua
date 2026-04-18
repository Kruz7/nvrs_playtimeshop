steamApiKey = ""
Discord_Webhook = "CHANGE_WEBHOOK"

function NvrsBanPlayer(source, reason)
    if NCHub.BanResource and NCHub.BanExport and GetResourceState(NCHub.BanResource) == "started" then
        local ok, err = pcall(function()
            exports[NCHub.BanResource][NCHub.BanExport](source, reason, true)
        end)
        if ok then
            return
        end
    end
    DropPlayer(source, "[nvrs_playtimeshop] " .. tostring(reason))
end

function NvrsLog(category, title, color, message)
    if not NCHub.UseRiaLogs then
        return
    end
    pcall(function()
        TriggerEvent("ria-logs:server:CreateLog", category, title or "", color or "white", message or "")
    end)
end

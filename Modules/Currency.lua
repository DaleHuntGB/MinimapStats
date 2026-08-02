local _, MS = ...

local Currencies = {
    { Key = "NebulousVoidcore", CurrencyID = 3418, Label = "Nebulous Voidcore"},
    { Key = "DawnlightManaflux", CurrencyID = 3378, Label = "Dawnlight Manaflux"},
    { Key = "RadiantSparkDust", CurrencyID = 3212, Label = "Radiant Spark Dust"},
}

MS.Currencies = Currencies

function MS:AddCurrencyTooltip(accentColour)
    local DB = MS.db.global.Tooltip.SystemStats.Currency
    if not DB.Enable then return end

    GameTooltip:AddLine("|c" .. accentColour .. "Currencies|r", 1, 1, 1)
    for _, currency in ipairs(Currencies) do
        if DB.Checklist[currency.Key] then
            local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currency.CurrencyID)
            if currencyInfo then
                local collectionStatus = currencyInfo.totalEarned < currencyInfo.maxQuantity and "|cFFCC4040Can Collect|r" or "|cFF40CC40Collected|r"
                GameTooltip:AddDoubleLine(string.format("|T%d:16:16|t |c%s%s|r", currencyInfo.iconFileID, accentColour, currencyInfo.name), string.format("|c%s%d (%s)|r", accentColour, currencyInfo.quantity, collectionStatus), 1, 1, 1, 1, 1, 1)
            end
        end
    end
    GameTooltip:AddLine(" ", 1, 1, 1)
end

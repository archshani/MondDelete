-------------------------------------------------
-- STATS TAB (Scrollable list + proper item links)
-------------------------------------------------

MondDelete = MondDelete or {}
MondDelete.Pro = MondDelete.Pro or {}
local Pro = MondDelete.Pro

-- small helper: clickable colored link if cached
local function MD_StatItemLink(itemID, preferLink)
    local idNum = tonumber(itemID) or itemID
    if preferLink and type(preferLink) == "string" and preferLink:find("|Hitem:") then
        return preferLink
    end
    if GetItemInfo then
        local name, link = GetItemInfo(idNum)
        if link and link:find("|Hitem:") then return link end
        if name and name ~= "" then
            return "|cffffffff|Hitem:" .. tostring(idNum) .. "|h[" .. name .. "]|h|r"
        end
    end
    return "|cffffffff|Hitem:" .. tostring(idNum) .. "|h[item:" .. tostring(idNum) .. "]|h|r"
end

local function MD_QuickSort(t, comp)
    table.sort(t, comp)
end

function Pro.StatsRefresh(p, noResetScroll)
    if not p then return end
    if Pro and Pro.EnsureDB then Pro:EnsureDB() end

    if p.title then p.title:SetText(Pro:L("STATS_TITLE")) end
    if p.resetBtn then p.resetBtn:SetText(Pro:L("STATS_RESET")) end
    if p.histBtn then p.histBtn:SetText(Pro:L("STATS_HISTORY")) end
    if p.chatBtn then p.chatBtn:SetText(Pro:L("STATS_TO_CHAT")) end

    local audit = MondDeleteDB and MondDeleteDB.audit or { total=0, itemCounts={}, history={} }
    local session = Pro._session or { total=0, itemCounts={}, history={} }

    local unique = 0
    for _ in pairs(audit.itemCounts or {}) do unique = unique + 1 end

    if p.totalFS then p.totalFS:SetText(Pro:L("STATS_TOTAL") .. " " .. (tonumber(audit.total) or 0)) end
    if p.sessFS then p.sessFS:SetText(Pro:L("STATS_SESSION") .. " " .. (tonumber(session.total) or 0)) end
    if p.uniqFS then p.uniqFS:SetText(Pro:L("STATS_UNIQUE") .. " " .. unique) end

    -- build sorted list (top by count, then name)
    local tmp = {}
    for id, c in pairs(audit.itemCounts or {}) do
        local cnt = tonumber(c) or 0
        if cnt > 0 then
            table.insert(tmp, { id = tonumber(id) or id, c = cnt })
        end
    end
    MD_QuickSort(tmp, function(a, b)
        if a.c ~= b.c then return a.c > b.c end
        -- try to sort by name if cached
        local an = ""
        local bn = ""
        if GetItemInfo then
            an = (GetItemInfo(a.id)) or ""
            bn = (GetItemInfo(b.id)) or ""
        end
        if an ~= bn then return string.lower(an) < string.lower(bn) end
        return tostring(a.id) < tostring(b.id)
    end)

    p._list = tmp

    local lines = p.lines or {}
    local totalLines = #tmp
    local visibleLines = p.visibleLines or 10

    if not noResetScroll and p.scroll then
        p.scroll:SetVerticalScroll(0)
    end

    local scrollOffset = 0
    if p.scroll then
        scrollOffset = math.floor((p.scroll:GetVerticalScroll() or 0) / (p.lineHeight or 16))
        if scrollOffset < 0 then scrollOffset = 0 end
    end

    if p.scroll and p.scrollChild then
        local totalHeight = totalLines * (p.lineHeight or 16)
        p.scrollChild:SetHeight(math.max(totalHeight, 1))
    end

    for i = 1, visibleLines do
        local row = lines[i]
        local idx = i + scrollOffset
        local d = tmp[idx]
        if d then
            row:Show()
            row.text:SetText(d.c .. "x " .. MD_StatItemLink(d.id))
        else
            row:Hide()
        end
    end

    if p.scroll and p.scrollBar then
        p.scrollBar:SetMinMaxValues(0, math.max(0, (totalLines - visibleLines) * (p.lineHeight or 16)))
        p.scrollBar:SetValue(p.scroll:GetVerticalScroll() or 0)
    end
end

MondDelete:RegisterTab(3, "Stats",

-- BUILD
function(p)
    if Pro and Pro.EnsureDB then Pro:EnsureDB() end
    Pro.StatsPanel = p

    p.lineHeight = 16
    p.visibleLines = 11

    if not p.title then
        p.title = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        p.title:SetPoint("TOPLEFT", 10, -6)
    end

    if not p.resetBtn then
        p.resetBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        p.resetBtn:SetSize(90, 18)
        p.resetBtn:SetPoint("TOPLEFT", 10, -32)
        p.resetBtn:SetScript("OnClick", function()
            local key = "MONDDELETE_RESET_STATS"
            StaticPopupDialogs[key] = StaticPopupDialogs[key] or {
                text = "",
                button1 = "",
                button2 = "",
                OnAccept = function()
                    if Pro and Pro.ResetAudit then Pro:ResetAudit() end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopupDialogs[key].text = Pro:L("STATS_RESET_Q") .. "\n\n" .. Pro:L("STATS_RESET_Q2")
            StaticPopupDialogs[key].button1 = Pro:L("COMMON_YES")
            StaticPopupDialogs[key].button2 = Pro:L("COMMON_NO")
            StaticPopup_Show(key)
        end)
    end

    if not p.histBtn then
        p.histBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        p.histBtn:SetSize(90, 18)
        p.histBtn:SetPoint("LEFT", p.resetBtn, "RIGHT", 8, 0)
        p.histBtn:SetScript("OnClick", function()
            if Pro and Pro.PrintHistory then Pro:PrintHistory(20) end
        end)
    end

    if not p.chatBtn then
        p.chatBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        p.chatBtn:SetSize(90, 18)
        p.chatBtn:SetPoint("LEFT", p.histBtn, "RIGHT", 8, 0)
        p.chatBtn:SetScript("OnClick", function()
            if Pro and Pro.PrintTop then Pro:PrintTop(10) end
        end)
    end

    if not p.totalFS then
        p.totalFS = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.totalFS:SetPoint("TOPLEFT", 10, -60)

        p.sessFS = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.sessFS:SetPoint("TOPLEFT", 10, -76)

        p.uniqFS = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.uniqFS:SetPoint("TOPLEFT", 10, -92)
    end

    -- Scroll area (mousewheel). Hide the template up/down buttons so it looks like Items.
    if not p.scroll then
        p.scroll = CreateFrame("ScrollFrame", "MondDeleteStatsScrollFrame", p, "UIPanelScrollFrameTemplate")
        p.scroll:SetPoint("TOPLEFT", 6, -118)
        p.scroll:SetSize(350, 175)
        p.scroll:EnableMouseWheel(true)

        p.scrollChild = CreateFrame("Frame", nil, p.scroll)
        p.scrollChild:SetSize(330, 1)
        p.scroll:SetScrollChild(p.scrollChild)

        -- convenience references (different client builds expose these differently)
        p.scrollBar = p.scroll.ScrollBar or _G["MondDeleteStatsScrollFrameScrollBar"]
        local sb = p.scrollBar
        if sb then
            local up = sb.ScrollUpButton or _G["MondDeleteStatsScrollFrameScrollBarScrollUpButton"]
            local down = sb.ScrollDownButton or _G["MondDeleteStatsScrollFrameScrollBarScrollDownButton"]
            if up then up:Hide() end
            if down then down:Hide() end
            -- keep inside the panel
            sb:ClearAllPoints()
            sb:SetPoint("TOPRIGHT", p.scroll, "TOPRIGHT", -2, -16)
            sb:SetPoint("BOTTOMRIGHT", p.scroll, "BOTTOMRIGHT", -2, 16)
        end

        p.scroll:SetScript("OnMouseWheel", function(self, delta)
            local cur = self:GetVerticalScroll() or 0
            local step = (p.lineHeight or 16) * 3
            local newVal = cur - delta * step
            if newVal < 0 then newVal = 0 end

            local total = (p._list and #p._list) or 0
            local maxVal = math.max(0, (total - (p.visibleLines or 10)) * (p.lineHeight or 16))
            if newVal > maxVal then newVal = maxVal end

            self:SetVerticalScroll(newVal)
            if Pro and Pro.StatsRefresh then Pro.StatsRefresh(p, true) end
        end)

        p.lines = {}
        for i = 1, p.visibleLines do
            local row = CreateFrame("Frame", nil, p.scrollChild)
            row:SetSize(320, p.lineHeight)
            row:SetPoint("TOPLEFT", 6, -(i - 1) * p.lineHeight)

            row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.text:SetPoint("LEFT", 0, 0)
            row.text:SetJustifyH("LEFT")
            row.text:SetWidth(310)

            p.lines[i] = row
        end
    end

    Pro.StatsRefresh(p)
end,

-- REFRESH
function(p)
    if Pro and Pro.StatsRefresh then Pro.StatsRefresh(p) end
end)

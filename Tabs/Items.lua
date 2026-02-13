-------------------------------------------------
-- ITEMS TAB (Search focus fixed + Clear fixed + scroll kept)
-------------------------------------------------

MondDelete = MondDelete or {}
MondDelete.Pro = MondDelete.Pro or {}
local Pro = MondDelete.Pro

local function MD_Chat(msg)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    else
        print(msg)
    end
end

local function MD_ItemLink(itemID, preferLink)
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

local function MD_WipeTable(t)
    if not t then return end
    for k in pairs(t) do t[k] = nil end
end

local function Items_Refresh(p, fromSearch)
    if Pro and Pro.EnsureDB then Pro:EnsureDB() end

    local function L(key, fallback)
        if Pro and Pro.L then return Pro:L(key) end
        return fallback
    end

    MondDeleteDB.items = MondDeleteDB.items or {}

    -- Update static texts (language changes)
    if p.help then p.help:SetText(L("ITEMS_HELP", "|cff00ff00Alt + Right Click|r to add item to the list")) end
    if p.searchLabel then p.searchLabel:SetText(L("COMMON_SEARCH", "Search:")) end
    if p.clearBtn then p.clearBtn:SetText(L("ITEMS_CLEAR", "Clear")) end
    if p.sortBtn then
        p.sortBtn:SetText(L("COMMON_SORT","Sort:") .. " " ..
            ((p.sortMode == "name") and L("SORT_NAME","Name") or L("SORT_QUALITY","Quality")))
    end

    local filter = p.filter or ""
    local fl = string.lower(filter)

    -- Build list
    local list, total = {}, 0
    for itemKey in pairs(MondDeleteDB.items) do
        total = total + 1
        local idForInfo = tonumber(itemKey) or itemKey
        local name, link, quality, _, _, _, _, _, _, icon = GetItemInfo(idForInfo)

        local ok = true
        if fl ~= "" then
            ok = false
            if name and string.find(string.lower(name), fl, 1, true) then ok = true end
            if not ok and string.find(tostring(itemKey), fl, 1, true) then ok = true end
        end

        if ok then
            table.insert(list, { key=itemKey, id=idForInfo, name=name, link=link, quality=quality, icon=icon })
        end
    end

    -- Sort
    if p.sortMode == "quality" then
        table.sort(list, function(a, b)
            local aq = a.quality; if aq == nil then aq = 999 end
            local bq = b.quality; if bq == nil then bq = 999 end
            if aq ~= bq then return aq < bq end
            local an = a.name or ""; local bn = b.name or ""
            if an ~= bn then return string.lower(an) < string.lower(bn) end
            return tostring(a.key) < tostring(b.key)
        end)
    else
        table.sort(list, function(a, b)
            local an = a.name or ""; local bn = b.name or ""
            if an ~= bn then return string.lower(an) < string.lower(bn) end
            local aq = a.quality; if aq == nil then aq = 999 end
            local bq = b.quality; if bq == nil then bq = 999 end
            if aq ~= bq then return aq < bq end
            return tostring(a.key) < tostring(b.key)
        end)
    end

    local prevScroll = p.scroll and p.scroll:GetVerticalScroll() or 0
    local changed = (p._lastFilter ~= filter) or (p._lastSort ~= p.sortMode)

    local shown = #list
    local rowW = math.max(200, (p.scroll:GetWidth() or 340) - 6)

    -- rows (reuse)
    for i = 1, shown do
        local d = list[i]
        local r = p.rows[i]

        if not r then
            r = CreateFrame("Frame", nil, p.content)
            r:SetSize(rowW, 34)

            r.icon = r:CreateTexture(nil, "OVERLAY")
            r.icon:SetSize(30, 30)
            r.icon:SetPoint("LEFT", 4, 0)

            r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            r.text:SetPoint("LEFT", r.icon, "RIGHT", 8, 0)
            r.text:SetWidth(rowW - 30 - 8 - 28)
            r.text:SetJustifyH("LEFT")

            r.del = CreateFrame("Button", nil, r, "UIPanelCloseButton")
            r.del:SetPoint("RIGHT", 0, 0)
            r.del:SetScale(0.7)
            r.del:SetScript("OnClick", function(self)
                local parent = self:GetParent()
                if parent and parent.itemKey ~= nil then
                    MondDeleteDB.items[parent.itemKey] = nil
                        local removedID = tonumber(parent.itemKey) or parent.itemKey
                        local removedLink = MD_ItemLink(removedID)
                        if Pro and Pro.L then
                            MD_Chat("|cff00ff00[MondDelete]|r " .. string.format(Pro:L("ITEMS_REMOVED"), removedLink))
                        else
                            MD_Chat("|cff00ff00[MondDelete]|r Removed from list: " .. removedLink)
                        end
                    Items_Refresh(p, false)
                end
            end)

            r.hl = r:CreateTexture(nil, "HIGHLIGHT")
            r.hl:SetAllPoints()
            r.hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            r.hl:SetBlendMode("ADD")

            r:SetScript("OnEnter", function(self)
                if not self.itemID and not self.itemKey then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                local _, link = GetItemInfo(self.itemID or self.itemKey)
                if link then
                    pcall(GameTooltip.SetHyperlink, GameTooltip, link)
                else
                    local num = tonumber(self.itemKey)
                    if num then pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. num) end
                end
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L("COMMON_ID","ID:") .. " " .. tostring(self.itemKey), 1,1,1)
                GameTooltip:AddLine(L("ITEMS_TIP_REMOVE","Click X to remove this item."), 0.7,0.7,0.7, true)
                GameTooltip:Show()
            end)
            r:SetScript("OnLeave", function() GameTooltip:Hide() end)

            p.rows[i] = r
        end

        r:SetSize(rowW, 34)
        r:SetPoint("TOPLEFT", 0, -(i - 1) * 36)
        r.itemKey = d.key
        r.itemID = d.id

        r.icon:SetTexture(d.icon or "Interface\\Icons\\INV_Misc_QuestionMark")

        if d.link then
            r.text:SetText(d.link)
        else
            local col = ITEM_QUALITY_COLORS[d.quality or 1]
            local label = d.name or ("Item " .. tostring(d.key))
            r.text:SetText((col and col.hex or "|cffffffff") .. label .. "|r")
        end

        r:Show()
    end

    for i = shown + 1, #p.rows do
        p.rows[i]:Hide()
        p.rows[i].itemKey = nil
        p.rows[i].itemID = nil
    end

    p.content:SetHeight(math.max(shown * 36, p.scroll:GetHeight()))

    local max = p.scroll:GetVerticalScrollRange()
    if changed then
        p.scroll:SetVerticalScroll(0)
    else
        p.scroll:SetVerticalScroll(math.max(0, math.min(prevScroll, max)))
    end
    p._lastFilter = filter
    p._lastSort = p.sortMode

    if p.count then
        p.count:SetText(L("COMMON_SHOWING","Showing") .. ": |cff00ff00" .. shown .. "|r / " ..
                        L("COMMON_TOTAL","Total") .. ": |cff00ff00" .. total .. "|r")
    end
end

MondDelete:RegisterTab(2, "Items",

-- BUILD
function(p)
    if Pro then
        Pro.ItemsPanel = p
        Pro.ItemsRefresh = Items_Refresh
        if Pro.EnsureDB then Pro:EnsureDB() end
    end

    p.filter = p.filter or ""
    p.sortMode = p.sortMode or "name"
    p.rows = p.rows or {}

    -- Help row
    if not p.help then
        p.help = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        p.help:SetPoint("TOPLEFT", 10, -6)
        p.help:SetWidth(340)
        p.help:SetJustifyH("LEFT")
    end

    -- Search row (moved down, so it doesn't overlap help)
    if not p.searchBox then
        p.searchBox = CreateFrame("EditBox", nil, p)
        p.searchBox:SetSize(180, 18)
        p.searchBox:SetPoint("TOPRIGHT", -12, -28)
        p.searchBox:SetAutoFocus(false)
        p.searchBox:SetMaxLetters(80)
        p.searchBox:SetFontObject("GameFontHighlightSmall")
        p.searchBox:SetTextInsets(6, 6, 3, 3)
        p.searchBox:EnableMouse(true)
        p.searchBox:SetScript("OnMouseDown", function(self) self:SetFocus() end)

        if p.searchBox.SetBackdrop then
            p.searchBox:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 10,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            p.searchBox:SetBackdropColor(0, 0, 0, 0.55)
            p.searchBox:SetBackdropBorderColor(0.8, 0.8, 0.8, 0.8)
        end

        p.searchLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        p.searchLabel:SetPoint("RIGHT", p.searchBox, "LEFT", -6, 0)

        p.searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        p.searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

        -- IMPORTANT: no SetTab() here -> keeps focus and allows typing full word
        p.searchBox:SetScript("OnTextChanged", function(self)
            if p._ignoreSearch then return end
            p.filter = self:GetText() or ""
            Items_Refresh(p, true)
        end)
    end

    p._ignoreSearch = true
    p.searchBox:SetText(p.filter or "")
    p._ignoreSearch = nil

    -- Buttons row
    if not p.sortBtn then
        p.sortBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        p.sortBtn:SetSize(140, 18)
        p.sortBtn:SetPoint("TOPLEFT", 10, -52)
        p.sortBtn:SetScript("OnClick", function()
            p.sortMode = (p.sortMode == "name") and "quality" or "name"
            Items_Refresh(p, false)
        end)
    end

    if not p.clearBtn then
        p.clearBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        p.clearBtn:SetSize(80, 18)
        p.clearBtn:SetPoint("LEFT", p.sortBtn, "RIGHT", 8, 0)
        p.clearBtn:SetScript("OnClick", function()
            local key = "MONDDELETE_CLEAR_ITEMS"
            StaticPopupDialogs[key] = StaticPopupDialogs[key] or {
                text = "",
                button1 = "",
                button2 = "",
                OnAccept = function()
                    if Pro and Pro.EnsureDB then Pro:EnsureDB() end
                    -- FIX: wipe active profile list, don't replace table
                    MD_WipeTable(MondDeleteDB.items)
                    Items_Refresh(p, false)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopupDialogs[key].text = (Pro and Pro.L and Pro:L("ITEMS_CLEAR_Q") or "Clear the delete list?") ..
                                          "\n\n" .. (Pro and Pro.L and Pro:L("ITEMS_CLEAR_Q2") or "This will remove ALL items from the list.")
            StaticPopupDialogs[key].button1 = (Pro and Pro.L and Pro:L("COMMON_YES") or "Yes")
            StaticPopupDialogs[key].button2 = (Pro and Pro.L and Pro:L("COMMON_NO") or "No")
            StaticPopup_Show(key)
        end)
    end

    -- ScrollFrame (keep your working scroll + arrow behavior)
    if not p.scroll then
        local sfName = "MondDelete_ItemsScrollFrame"
        if _G[sfName] then
            p.scroll = _G[sfName]
            p.scroll:SetParent(p)
            p.scroll:ClearAllPoints()
        else
            p.scroll = CreateFrame("ScrollFrame", sfName, p, "UIPanelScrollFrameTemplate")
        end

        p.scroll:SetPoint("TOPLEFT", 10, -76)
        p.scroll:SetPoint("BOTTOMRIGHT", -52, 24)

        p.content = p.content or CreateFrame("Frame", nil, p.scroll)
        p.content:SetSize(1, 1)
        p.scroll:SetScrollChild(p.content)

        p.scroll:EnableMouseWheel(true)
        p.scroll:SetScript("OnMouseWheel", function(self, delta)
            local cur = self:GetVerticalScroll()
            local max = self:GetVerticalScrollRange()
            local step = 30
            if delta < 0 then
                self:SetVerticalScroll(math.min(cur + step, max))
            else
                self:SetVerticalScroll(math.max(cur - step, 0))
            end
        end)

        local sb = _G[sfName .. "ScrollBar"]
        if sb and sb.ScrollUpButton and sb.ScrollDownButton then
            sb.ScrollUpButton:SetScript("OnClick", function()
                local cur = p.scroll:GetVerticalScroll()
                p.scroll:SetVerticalScroll(math.max(cur - 30, 0))
            end)
            sb.ScrollDownButton:SetScript("OnClick", function()
                local cur = p.scroll:GetVerticalScroll()
                local max = p.scroll:GetVerticalScrollRange()
                p.scroll:SetVerticalScroll(math.min(cur + 30, max))
            end)
        end
    end

    if not p.count then
        p.count = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        p.count:SetPoint("BOTTOMLEFT", 10, 5)
    end

    Items_Refresh(p, false)
end,

-- REFRESH
function(p)
    Items_Refresh(p, false)
end)

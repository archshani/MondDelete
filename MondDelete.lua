-- =========================
-- MondDelete Core
-- =========================

MondDelete = {}
local addonName = ...
MondDelete.tabs  = {}
MondDelete.pages = {}

local prefix = "|cff00ff00[MondDelete]|r "
local isDeleting = false
local lastDeleteTime = 0
-------------------------------------------------
-- DB
-------------------------------------------------
local function InitDB()
    MondDeleteDB = MondDeleteDB or {}

    MondDeleteDB.items = MondDeleteDB.items or {}
    MondDeleteDB.bags  = MondDeleteDB.bags or {
        [0]=true,[1]=true,[2]=true,[3]=true,[4]=true
    }

    MondDeleteDB.stats = MondDeleteDB.stats or {
        total = 0,
        itemCounts = {}
    }

    MondDeleteDB.settings = MondDeleteDB.settings or {
        chatLog       = true,
        confirmStart  = true,
        confirmEach   = false,
        safeMode      = true,   -- не удалять rare+
        ignoreEquipped= true,   -- не удалять экипированное
    }

    -- enabled flag (backward compatible with older SavedVariables)
    if MondDeleteDB.settings.enabled == nil then
        if MondDeleteDB.enabled ~= nil then
            MondDeleteDB.settings.enabled = MondDeleteDB.enabled
        else
            MondDeleteDB.settings.enabled = false
        end
    end
    -- keep legacy field in sync (some code still reads MondDeleteDB.enabled)
    MondDeleteDB.enabled = MondDeleteDB.settings.enabled

end

-------------------------------------------------
-- SAFETY
-------------------------------------------------
local PROTECTED_ITEM_NAME = "Old Member Gem"

local function IsSafeToDelete(itemID)
    if MondDeleteDB.settings.ignoreEquipped and IsEquippedItem(itemID) then
        return false
    end

    -- защита ТОЛЬКО для Old Member Gem
    local name = GetItemInfo(itemID)
    if name == PROTECTED_ITEM_NAME then
        return false
    end

    return true
end

-------------------------------------------------
-- MAIN FRAME
-------------------------------------------------
local f = CreateFrame("Frame", "MondDeleteMainFrame", UIParent)
f:SetSize(400, 430)
f:SetPoint("CENTER")
f:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left=11, right=12, top=12, bottom=11 }
})
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()

MondDelete.frame = f

CreateFrame("Button", nil, f, "UIPanelCloseButton"):SetPoint("TOPRIGHT", -5, -5)

-- Title
local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("|cff00ff00Mond|rDelete Pro")

-------------------------------------------------
-- TAB SYSTEM
-------------------------------------------------
function MondDelete:RegisterTab(id, name, build, refresh)
    self.tabs[id] = {
        name = name,
        build = build,
        refresh = refresh
    }
end

function MondDelete:SetTab(id)
    for _, p in pairs(self.pages) do
        p:Hide()
    end

    local t = self.tabs[id]
    if not t then return end

    if not self.pages[id] then
        local p = CreateFrame("Frame", nil, f)
        p:SetSize(360, 260)
        p:SetPoint("TOP", 0, -90)
        self.pages[id] = p
        t.build(p)
    end

    self.pages[id]:Show()
    if t.refresh then
        t.refresh(self.pages[id])
    end
end

-------------------------------------------------
-- TAB BUTTONS
-------------------------------------------------
local tabButtons = {}

local function BuildTabButtons()
    local i = 1
    for id, tab in pairs(MondDelete.tabs) do
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(70, 24)
        b:SetPoint("TOPLEFT", 15 + (i-1)*75, -50)
        b:SetText(tab.name)
        b:SetScript("OnClick", function()
            MondDelete:SetTab(id)
        end)
        tabButtons[id] = b
        i = i + 1
    end
end

-------------------------------------------------
-- ENGINE (удаление)
-------------------------------------------------
local function RunDeleteEngine()
    if isDeleting then return end

    local now = GetTime()
    if now - lastDeleteTime < 1 then return end
    lastDeleteTime = now

    isDeleting = true

    local deletedThisRun = {}
    local count = 0

    for bag = 0, 4 do
        if MondDeleteDB.bags[bag] then
            for slot = 1, GetContainerNumSlots(bag) do
                local itemID = GetContainerItemID(bag, slot)
                if itemID
                and MondDeleteDB.items[itemID]
                and IsSafeToDelete(itemID) then

                    ClearCursor()
                    PickupContainerItem(bag, slot)
                    DeleteCursorItem()

                    MondDeleteDB.stats.total = MondDeleteDB.stats.total + 1
                    MondDeleteDB.stats.itemCounts[itemID] =
                        (MondDeleteDB.stats.itemCounts[itemID] or 0) + 1
                    deletedThisRun[itemID] =
                        (deletedThisRun[itemID] or 0) + 1

                    count = count + 1
                    if count >= 33 then break end
                end
            end
        end
        if count >= 33 then break end
    end

    if MondDeleteDB.settings.chatLog and next(deletedThisRun) then
        -- выводим только один раз за один запуск
        local output = {}
        for itemID, count in pairs(deletedThisRun) do
            local link = select(2, GetItemInfo(itemID))
            if link then
                table.insert(output, count.."x "..link)
            end
        end
        if #output > 0 then
            print(prefix.."Deleted: "..table.concat(output, ", "))
        end
    end

    isDeleting = false
end

-------------------------------------------------
-- ALT + RMB : ADD ONLY + CHAT LINK
-------------------------------------------------
local old_OnClick = ContainerFrameItemButton_OnModifiedClick
function ContainerFrameItemButton_OnModifiedClick(self, button)
    if button == "RightButton" and IsAltKeyDown() then
        local bag = self:GetParent():GetID()
        local slot = self:GetID()
        local itemID = GetContainerItemID(bag, slot)

        if itemID and not MondDeleteDB.items[itemID] then
            MondDeleteDB.items[itemID] = true

            local link = GetItemInfo(itemID)
            if link and MondDeleteDB.settings.chatLog then
                print("|cff00ff00[MondDelete]|r Added to delete list: "..link)
            end

            if MondDelete.pages[2] then
                MondDelete:SetTab(2)
            end
        end
        return
    end
    old_OnClick(self, button)
end



-------------------------------------------------
-- SLASH
-------------------------------------------------
SLASH_MONDDELETE1 = "/md"
SlashCmdList["MONDDELETE"] = function()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        MondDelete:SetTab(1)
    end
end

-------------------------------------------------
-- EVENTS
-------------------------------------------------
local e = CreateFrame("Frame")
e:RegisterEvent("ADDON_LOADED")
e:RegisterEvent("BAG_UPDATE")

e:SetScript("OnEvent", function(_, ev, arg)
    if ev == "ADDON_LOADED" and arg == addonName then
        InitDB()
        BuildTabButtons()
        print(prefix.."loaded. Type |cff00ff00/md|r")
    elseif ev == "BAG_UPDATE" and MondDeleteDB and MondDeleteDB.settings and MondDeleteDB.settings.enabled then
        RunDeleteEngine()
    end
end)

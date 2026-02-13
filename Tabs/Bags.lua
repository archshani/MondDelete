-- =================================
-- MondDelete :: Bags Tab (ETALON)
-- =================================

MondDelete:RegisterTab(1, "Bags",

-- BUILD
function(p)
    p.rows = {}

    local title = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -5)
    title:SetText("|cff00ff00Select bags to scan:|r")

    for bag = 0, 4 do
        local r = CreateFrame("Frame", nil, p)
        r:SetSize(300, 36)
        r:SetPoint("TOPLEFT", 10, -25 - bag * 38)

        r.icon = r:CreateTexture(nil, "OVERLAY")
        r.icon:SetSize(32, 32)
        r.icon:SetPoint("LEFT", 0, 0)

        r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        r.text:SetPoint("LEFT", r.icon, "RIGHT", 8, 0)
        r.text:SetWidth(200)
        r.text:SetJustifyH("LEFT")

        r.cb = CreateFrame("CheckButton", nil, r, "UICheckButtonTemplate")
        r.cb:SetPoint("RIGHT", 0, 0)

        r.cb:SetScript("OnClick", function(self)
            MondDeleteDB.bags[bag] = self:GetChecked()
        end)

        p.rows[bag] = r
    end
end,

-- REFRESH
function(p)
    for bag = 0, 4 do
        local r = p.rows[bag]
        if not r then return end

        local icon, text

        if bag == 0 then
            icon = "Interface\\Buttons\\Button-Backpack-Up"
            text = "Backpack"
        else
            local invID = ContainerIDToInventoryID(bag)
            local itemID = GetInventoryItemID("player", invID)

            if itemID then
                icon = GetItemIcon(itemID)
                text = GetItemInfo(itemID) or ("Bag " .. bag)
            else
                icon = "Interface\\Icons\\INV_Misc_Bag_08"
                text = "Empty Slot"
            end
        end

        r.icon:SetTexture(icon)
        r.text:SetText(text)
        r.cb:SetChecked(MondDeleteDB.bags[bag])
    end
end)

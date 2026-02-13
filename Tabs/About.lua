-------------------------------------------------
-- ABOUT TAB (Author/Server/Discord not translated)
-- Design kept the same; only added live refresh on language change.
-------------------------------------------------

MondDelete = MondDelete or {}
MondDelete.Pro = MondDelete.Pro or {}
local Pro = MondDelete.Pro

local function ApplyAboutText(p)
    local function L(key, fallback)
        if Pro and Pro.L then return Pro:L(key) end
        return fallback
    end

    if p.sub then p.sub:SetText(L("ABOUT_SUB", "Auto-delete items by your list.")) end

    if p.body then
        p.body:SetText(
            "• " .. L("ABOUT_TIP1", "Bags: select bags to scan") .. "\n" ..
            "• " .. L("ABOUT_TIP2", "Items: Alt+RightClick an item to add it") .. "\n" ..
            "• " .. L("ABOUT_TIP3", "Settings: Start/Stop, confirmations, chat log") .. "\n" ..
            "• " .. L("ABOUT_TIP4", "Stats: history and statistics")
        )
    end
end

-- expose refresh for Settings.lua (Pro:RefreshUI)
function Pro.AboutRefresh(p)
    if Pro and Pro.EnsureDB then Pro:EnsureDB() end
    ApplyAboutText(p)
end

MondDelete:RegisterTab(5, "About",

function(p)
    if Pro and Pro.EnsureDB then Pro:EnsureDB() end
    Pro.AboutPanel = p

    if not p.title then
        p.title = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        p.title:SetPoint("TOP", 0, -12)

        p.sub = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.sub:SetPoint("TOP", 0, -32)

        p.body = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        p.body:SetPoint("TOPLEFT", 16, -64)
        p.body:SetWidth(340)
        p.body:SetJustifyH("LEFT")

        p.author = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.author:SetPoint("BOTTOMLEFT", 16, 40)

        p.server = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.server:SetPoint("BOTTOMLEFT", 16, 24)

        p.discordBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        p.discordBtn:SetSize(190, 18)
        p.discordBtn:SetPoint("BOTTOMLEFT", 16, 6)

        p.discordBtn.icon = p.discordBtn:CreateTexture(nil, "OVERLAY")
        p.discordBtn.icon:SetSize(16, 16)
        p.discordBtn.icon:SetPoint("LEFT", 6, 0)
        p.discordBtn.icon:SetTexture("Interface\\Icons\\INV_Misc_GroupLooking")

        p.discordBtn.textFS = p.discordBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.discordBtn.textFS:SetPoint("LEFT", p.discordBtn.icon, "RIGHT", 6, 0)
        p.discordBtn.textFS:SetText("discord.com/invite/XGrsWvGCuS")

        p.discordBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Discord:", 1,1,1, true)
            GameTooltip:AddLine("discord.com/invite/XGrsWvGCuS", 0.7,0.7,0.7, true)
            GameTooltip:Show()
        end)
        p.discordBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        p.discordBtn:SetScript("OnClick", function()
            local link = "discord.com/invite/XGrsWvGCuS"
            if ChatFrame_OpenChat then
                ChatFrame_OpenChat(link)
            else
                if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
                    DEFAULT_CHAT_FRAME:AddMessage(link)
                else
                    print(link)
                end
            end
        end)
    end

    p.title:SetText("|cff00ff00MondDelete Pro|r")

    ApplyAboutText(p)

    p.author:SetText("|cffaaaaaaAuthor: Marusp|r")
    p.server:SetText("|cffaaaaaaServer: mond-wow.com|r")
end,

function(p)
    if Pro and Pro.AboutRefresh then Pro.AboutRefresh(p) end
end)

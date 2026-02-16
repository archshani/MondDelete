-------------------------------------------------
-- SETTINGS + CORE (Top-5 Languages, Profiles, Hooks)
-- NOTE: Bags.lua is read-only. This file owns: locale, profiles, deletion hooks, settings UI.
-------------------------------------------------

MondDelete = MondDelete or {}
MondDelete.Pro = MondDelete.Pro or {}
local Pro = MondDelete.Pro

-------------------------------------------------
-- Helpers
-------------------------------------------------
local function MD_Chat(msg)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    else
        print(msg)
    end
end

local function MD_Trim(s)
    if not s then return "" end
    s = tostring(s)
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

local function MD_ParseItemIDFromLink(link)
    if not link then return nil end
    local id = string.match(link, "item:(%d+)")
    return id and tonumber(id) or nil
end

local function MD_WipeTable(t)
    if not t then return end
    for k in pairs(t) do t[k] = nil end
end

local function MD_Now()
    if GetTime then return GetTime() end
    if time then return time() end
    return 0
end

local function MD_TimeStamp()
    return (date and date("%H:%M:%S")) or ""
end

-- Best-effort clickable link (already colored if cached by client).
local function MD_MakeItemLink(itemID, preferLink)
    local idNum = tonumber(itemID) or itemID
    if preferLink and type(preferLink) == "string" and preferLink:find("|Hitem:") then
        return preferLink
    end

    if GetItemInfo then
        local name, link = GetItemInfo(idNum)
        if link and link:find("|Hitem:") then
            return link
        end
        if name and name ~= "" then
            return "|cffffffff|Hitem:" .. tostring(idNum) .. "|h[" .. name .. "]|h|r"
        end
    end

    return "|cffffffff|Hitem:" .. tostring(idNum) .. "|h[item:" .. tostring(idNum) .. "]|h|r"
end

-------------------------------------------------
-- Locale (Top-5, NO Russian, NO AUTO)
-------------------------------------------------
function Pro:InitLocale()
    if self._localeInit then return end
    self._localeInit = true

    self.translations = {
        enUS = {
            -- tabs
            TAB_BAGS="Bags", TAB_ITEMS="Items", TAB_STATS="Stats", TAB_SETTINGS="Settings", TAB_ABOUT="About",

            -- common
            COMMON_SEARCH="Search:", COMMON_SORT="Sort:", COMMON_TOTAL="Total", COMMON_SHOWING="Showing",
            COMMON_YES="Yes", COMMON_NO="No",

            SORT_NAME="Name", SORT_QUALITY="Quality", SORT_COUNT="Count",

            -- items
            ITEMS_HELP="|cff00ff00Alt + Right Click|r to add item to the list",
            ITEMS_CLEAR="Clear",
            ITEMS_CLEAR_Q="Clear the delete list?",
            ITEMS_CLEAR_Q2="This will remove ALL items from the list.",
            ITEMS_ADDED="Added to list: %s",
            ITEMS_REMOVED="Removed from list: %s",

            -- stats
            STATS_TITLE="Statistics",
            STATS_RESET="Reset",
            STATS_TO_CHAT="To chat",
            STATS_HISTORY="History",
            STATS_TOTAL="Total deleted:",
            STATS_SESSION="This session:",
            STATS_UNIQUE="Unique items:",
            STATS_RESET_Q="Reset statistics?",
            STATS_RESET_Q2="This will clear totals and history.",

            -- settings
            SET_TITLE="Settings",
            SET_DESC="Profiles, language, safety and chat log.",
            SET_PROFILE="Profile:",
            SET_PROFILE_NEW="New profile…",
            SET_PROFILE_NEW_PROMPT="Enter profile name:",
            SET_PROFILE_CHANGED="Profile changed: %s",

            SET_LANGUAGE="Language:",
            LANG_CHANGED="Language set: %s",

            SET_STATUS="Status:",
            SET_ON="ON", SET_OFF="OFF",
            SET_START="Start", SET_STOP="Stop",
            SET_CHATLOG="Write deleted items to chat",
            SET_CONFIRM_START="Confirm START",
            SET_CONFIRM_EACH="Confirm each item",
            SET_TIP_CONFIRM_EACH="Shows a confirmation popup for every single item before it is deleted.",
            SET_TIP_START="Enables/disables deletion.",
            SET_TIP_CHAT="Prints one line per deletion.",
            SET_TIP_STARTCONF="Shows a confirmation with the list of items before enabling.",
            SET_SILENTMODE="Silent Mode",
            SET_TIP_SILENTMODE="Hides all chat messages from the addon.",

            -- popups
            POP_CONFIRM_TEXT="Enable for profile: %s\n\nItems in list:\n%s",
            POP_DELETE_TEXT="Delete %dx %s ?",

            -- chat messages
            MSG_DISABLED="[MondDelete] is DISABLED. Enable it in Settings.",
            MSG_DELETED="Deleted:",
            MSG_HISTORY_EMPTY="History: (empty)",
            MSG_HISTORY_TITLE="History (last %d):",
            MSG_TOP_TITLE="Total deleted: %d",

            -- about (only tips are translated; author/server/discord are not)
            ABOUT_SUB="Auto-delete items by your list.",
            ABOUT_TIP1="Bags: select bags to scan",
            ABOUT_TIP2="Items: Alt+RightClick an item to add it",
            ABOUT_TIP3="Settings: Start/Stop, confirmations, chat log",
            ABOUT_TIP4="Stats: history and statistics",
        },

        frFR = {
            TAB_BAGS="Sacs", TAB_ITEMS="Objets", TAB_STATS="Stats", TAB_SETTINGS="Options", TAB_ABOUT="À propos",

            COMMON_SEARCH="Rechercher :", COMMON_SORT="Trier :", COMMON_TOTAL="Total", COMMON_SHOWING="Affiché",
            COMMON_YES="Oui", COMMON_NO="Non",

            SORT_NAME="Nom", SORT_QUALITY="Qualité", SORT_COUNT="Qté",

            ITEMS_HELP="|cff00ff00Alt + Clic droit|r pour ajouter l'objet",
            ITEMS_CLEAR="Vider",
            ITEMS_CLEAR_Q="Vider la liste ?",
            ITEMS_CLEAR_Q2="Cela supprimera TOUS les objets de la liste.",
            ITEMS_ADDED="Ajouté à la liste : %s",
            ITEMS_REMOVED="Retiré de la liste : %s",

            STATS_TITLE="Statistiques",
            STATS_RESET="Reset",
            STATS_TO_CHAT="Chat",
            STATS_HISTORY="Historique",
            STATS_TOTAL="Total supprimé :",
            STATS_SESSION="Cette session :",
            STATS_UNIQUE="Objets uniques :",
            STATS_RESET_Q="Réinitialiser les stats ?",
            STATS_RESET_Q2="Efface total et historique.",

            SET_TITLE="Paramètres",
            SET_DESC="Profils, langue, sécurité et log chat.",
            SET_PROFILE="Profil :",
            SET_PROFILE_NEW="Nouveau profil…",
            SET_PROFILE_NEW_PROMPT="Nom du profil :",
            SET_PROFILE_CHANGED="Profil changé : %s",

            SET_LANGUAGE="Langue :",
            LANG_CHANGED="Langue changée : %s",

            SET_STATUS="Statut :",
            SET_ON="ON", SET_OFF="OFF",
            SET_START="Start", SET_STOP="Stop",
            SET_CHATLOG="Écrire les suppressions dans le chat",
            SET_CONFIRM_START="Confirmer START",
            SET_CONFIRM_EACH="Confirmer chaque objet",
            SET_TIP_CONFIRM_EACH="Affiche une fenêtre de confirmation pour chaque objet avant sa suppression.",
            SET_TIP_START="Active/désactive la suppression.",
            SET_TIP_CHAT="1 ligne par suppression.",
            SET_TIP_STARTCONF="Affiche la liste avant d'activer.",
            SET_SILENTMODE="Mode silencieux",
            SET_TIP_SILENTMODE="Masque tous les messages de l'addon dans le chat.",

            POP_CONFIRM_TEXT="Activer pour le profil : %s\n\nObjets dans la liste :\n%s",
            POP_DELETE_TEXT="Supprimer %dx %s ?",

            MSG_DISABLED="[MondDelete] est DÉSACTIVÉ. Activez-le dans Paramètres.",
            MSG_DELETED="Supprimé :",
            MSG_HISTORY_EMPTY="Historique : (vide)",
            MSG_HISTORY_TITLE="Historique (derniers %d) :",
            MSG_TOP_TITLE="Total supprimé : %d",

            ABOUT_SUB="Suppression auto par liste.",
            ABOUT_TIP1="Bags : choisir les sacs",
            ABOUT_TIP2="Items : Alt+Clic droit pour ajouter",
            ABOUT_TIP3="Settings : Start/Stop, confirmations, chat",
            ABOUT_TIP4="Stats : historique et stats",
        },

        deDE = {
            TAB_BAGS="Taschen", TAB_ITEMS="Items", TAB_STATS="Stats", TAB_SETTINGS="Einstellungen", TAB_ABOUT="Info",

            COMMON_SEARCH="Suche:", COMMON_SORT="Sort:", COMMON_TOTAL="Gesamt", COMMON_SHOWING="Angezeigt",
            COMMON_YES="Ja", COMMON_NO="Nein",

            SORT_NAME="Name", SORT_QUALITY="Qualität", SORT_COUNT="Anz.",

            ITEMS_HELP="|cff00ff00Alt + Rechtsklick|r um Item hinzuzufügen",
            ITEMS_CLEAR="Leeren",
            ITEMS_CLEAR_Q="Liste leeren?",
            ITEMS_CLEAR_Q2="Dies entfernt ALLE Items aus der Liste.",
            ITEMS_ADDED="Zur Liste hinzugefügt: %s",
            ITEMS_REMOVED="Aus der Liste entfernt: %s",

            STATS_TITLE="Statistik",
            STATS_RESET="Reset",
            STATS_TO_CHAT="Chat",
            STATS_HISTORY="Verlauf",
            STATS_TOTAL="Insgesamt gelöscht:",
            STATS_SESSION="Diese Sitzung:",
            STATS_UNIQUE="Einzigartige Items:",
            STATS_RESET_Q="Statistik zurücksetzen?",
            STATS_RESET_Q2="Löscht Total und Verlauf.",

            SET_TITLE="Einstellungen",
            SET_DESC="Profile, Sprache, Sicherheit und Chat-Log.",
            SET_PROFILE="Profil:",
            SET_PROFILE_NEW="Neues Profil…",
            SET_PROFILE_NEW_PROMPT="Profilname:",
            SET_PROFILE_CHANGED="Profil geändert: %s",

            SET_LANGUAGE="Sprache:",
            LANG_CHANGED="Sprache geändert: %s",

            SET_STATUS="Status:",
            SET_ON="AN", SET_OFF="AUS",
            SET_START="Start", SET_STOP="Stop",
            SET_CHATLOG="Gelöschte Items im Chat anzeigen",
            SET_CONFIRM_START="START bestätigen",
            SET_CONFIRM_EACH="Jedes Item bestätigen",
            SET_TIP_CONFIRM_EACH="Zeigt für jedes einzelne Item ein Bestätigungsfenster an, bevor es gelöscht wird.",
            SET_TIP_START="Aktiviert/Deaktiviert Löschen.",
            SET_TIP_CHAT="1 Zeile pro Löschung.",
            SET_TIP_STARTCONF="Zeigt Liste vor Aktivierung.",
            SET_SILENTMODE="Stiller Modus",
            SET_TIP_SILENTMODE="Blendet alle Chat-Nachrichten des Addons aus.",

            POP_CONFIRM_TEXT="Aktivieren für Profil: %s\n\nItems in Liste:\n%s",
            POP_DELETE_TEXT="%dx %s löschen?",

            MSG_DISABLED="[MondDelete] ist AUS. In Einstellungen aktivieren.",
            MSG_DELETED="Gelöscht:",
            MSG_HISTORY_EMPTY="Verlauf: (leer)",
            MSG_HISTORY_TITLE="Verlauf (letzte %d):",
            MSG_TOP_TITLE="Insgesamt gelöscht: %d",

            ABOUT_SUB="Auto-Löschen per Liste.",
            ABOUT_TIP1="Bags: Taschen wählen",
            ABOUT_TIP2="Items: Alt+Rechtsklick hinzufügen",
            ABOUT_TIP3="Settings: Start/Stop, Bestätigungen",
            ABOUT_TIP4="Stats: Verlauf und Statistik",
        },

        esES = {
            TAB_BAGS="Bolsas", TAB_ITEMS="Objetos", TAB_STATS="Stats", TAB_SETTINGS="Ajustes", TAB_ABOUT="Acerca de",

            COMMON_SEARCH="Buscar:", COMMON_SORT="Orden:", COMMON_TOTAL="Total", COMMON_SHOWING="Mostrando",
            COMMON_YES="Sí", COMMON_NO="No",

            SORT_NAME="Nombre", SORT_QUALITY="Calidad", SORT_COUNT="Cant.",

            ITEMS_HELP="|cff00ff00Alt + Clic derecho|r para añadir",
            ITEMS_CLEAR="Limpiar",
            ITEMS_CLEAR_Q="¿Limpiar la lista?",
            ITEMS_CLEAR_Q2="Esto eliminará TODOS los objetos de la lista.",
            ITEMS_ADDED="Añadido a la lista: %s",
            ITEMS_REMOVED="Eliminado de la lista: %s",

            STATS_TITLE="Estadísticas",
            STATS_RESET="Reset",
            STATS_TO_CHAT="Chat",
            STATS_HISTORY="Historial",
            STATS_TOTAL="Total borrado:",
            STATS_SESSION="Esta sesión:",
            STATS_UNIQUE="Objetos únicos:",
            STATS_RESET_Q="¿Reiniciar estadísticas?",
            STATS_RESET_Q2="Borra total e historial.",

            SET_TITLE="Ajustes",
            SET_DESC="Perfiles, idioma, seguridad y chat.",
            SET_PROFILE="Perfil:",
            SET_PROFILE_NEW="Nuevo perfil…",
            SET_PROFILE_NEW_PROMPT="Nombre del perfil:",
            SET_PROFILE_CHANGED="Perfil cambiado: %s",

            SET_LANGUAGE="Idioma:",
            LANG_CHANGED="Idioma cambiado: %s",

            SET_STATUS="Estado:",
            SET_ON="ON", SET_OFF="OFF",
            SET_START="Start", SET_STOP="Stop",
            SET_CHATLOG="Escribir borrados en el chat",
            SET_CONFIRM_START="Confirmar START",
            SET_CONFIRM_EACH="Confirmar cada objeto",
            SET_TIP_CONFIRM_EACH="Muestra una ventana de confirmación para cada objeto antes de borrarlo.",
            SET_TIP_START="Activa/Desactiva el borrado.",
            SET_TIP_CHAT="1 línea por borrado.",
            SET_TIP_STARTCONF="Muestra la lista antes de activar.",
            SET_SILENTMODE="Modo silencioso",
            SET_TIP_SILENTMODE="Oculta todos los mensajes del addon en el chat.",

            POP_CONFIRM_TEXT="Activar para perfil: %s\n\nObjetos en la lista:\n%s",
            POP_DELETE_TEXT="¿Borrar %dx %s?",

            MSG_DISABLED="[MondDelete] DESACTIVADO. Actívalo en Ajustes.",
            MSG_DELETED="Borrado:",
            MSG_HISTORY_EMPTY="Historial: (vacío)",
            MSG_HISTORY_TITLE="Historial (últimos %d):",
            MSG_TOP_TITLE="Total borrado: %d",

            ABOUT_SUB="Borrado automático por lista.",
            ABOUT_TIP1="Bags: seleccionar bolsas",
            ABOUT_TIP2="Items: Alt+Clic derecho para añadir",
            ABOUT_TIP3="Settings: Start/Stop, confirmaciones",
            ABOUT_TIP4="Stats: historial y estadísticas",
        },

        itIT = {
            TAB_BAGS="Borse", TAB_ITEMS="Oggetti", TAB_STATS="Stats", TAB_SETTINGS="Impostazioni", TAB_ABOUT="Info",

            COMMON_SEARCH="Cerca:", COMMON_SORT="Ordina:", COMMON_TOTAL="Totale", COMMON_SHOWING="Mostrati",
            COMMON_YES="Sì", COMMON_NO="No",

            SORT_NAME="Nome", SORT_QUALITY="Qualità", SORT_COUNT="Qtà",

            ITEMS_HELP="|cff00ff00Alt + Click destro|r per aggiungere",
            ITEMS_CLEAR="Pulisci",
            ITEMS_CLEAR_Q="Pulire la lista?",
            ITEMS_CLEAR_Q2="Questo rimuove TUTTI gli oggetti dalla lista.",
            ITEMS_ADDED="Aggiunto alla lista: %s",
            ITEMS_REMOVED="Rimosso dalla lista: %s",

            STATS_TITLE="Statistiche",
            STATS_RESET="Reset",
            STATS_TO_CHAT="Chat",
            STATS_HISTORY="Cronologia",
            STATS_TOTAL="Totale eliminato:",
            STATS_SESSION="Questa sessione:",
            STATS_UNIQUE="Oggetti unici:",
            STATS_RESET_Q="Resettare statistiche?",
            STATS_RESET_Q2="Cancella totale e cronologia.",

            SET_TITLE="Impostazioni",
            SET_DESC="Profili, lingua, sicurezza e chat.",
            SET_PROFILE="Profilo:",
            SET_PROFILE_NEW="Nuovo profilo…",
            SET_PROFILE_NEW_PROMPT="Nome profilo:",
            SET_PROFILE_CHANGED="Profilo cambiato: %s",

            SET_LANGUAGE="Lingua:",
            LANG_CHANGED="Lingua cambiata: %s",

            SET_STATUS="Stato:",
            SET_ON="ON", SET_OFF="OFF",
            SET_START="Start", SET_STOP="Stop",
            SET_CHATLOG="Scrivi eliminazioni in chat",
            SET_CONFIRM_START="Conferma START",
            SET_CONFIRM_EACH="Conferma ogni oggetto",
            SET_TIP_CONFIRM_EACH="Mostra un popup di conferma per ogni singolo oggetto prima che venga eliminato.",
            SET_TIP_START="Abilita/Disabilita eliminazione.",
            SET_TIP_CHAT="1 riga per eliminazione.",
            SET_TIP_STARTCONF="Mostra la lista prima di attivare.",
            SET_SILENTMODE="Modalità silenziosa",
            SET_TIP_SILENTMODE="Nasconde tutti i messaggi dell'addon nella chat.",

            POP_CONFIRM_TEXT="Abilitare per profilo: %s\n\nOggetti in lista:\n%s",
            POP_DELETE_TEXT="Eliminare %dx %s ?",

            MSG_DISABLED="[MondDelete] DISATTIVATO. Attivalo in Impostazioni.",
            MSG_DELETED="Eliminato:",
            MSG_HISTORY_EMPTY="Cronologia: (vuoto)",
            MSG_HISTORY_TITLE="Cronologia (ultimi %d):",
            MSG_TOP_TITLE="Totale eliminato: %d",

            ABOUT_SUB="Eliminazione automatica per lista.",
            ABOUT_TIP1="Bags: seleziona borse",
            ABOUT_TIP2="Items: Alt+Click destro per aggiungere",
            ABOUT_TIP3="Settings: Start/Stop, conferme",
            ABOUT_TIP4="Stats: cronologia e statistiche",
        },
    }
end

function Pro:EnsureDB()
    MondDeleteDB = MondDeleteDB or {}
    MondDeleteDB.settings = MondDeleteDB.settings or {}

    -- default language: English
    if MondDeleteDB.settings.lang == nil or MondDeleteDB.settings.lang == "" then
        MondDeleteDB.settings.lang = "enUS"
    end

    if MondDeleteDB.settings.enabled == nil then MondDeleteDB.settings.enabled = true end
    if MondDeleteDB.settings.chatLog == nil then MondDeleteDB.settings.chatLog = true end
    if MondDeleteDB.settings.confirmStart == nil then MondDeleteDB.settings.confirmStart = false end
    if MondDeleteDB.settings.confirmEach == nil then MondDeleteDB.settings.confirmEach = false end
    if MondDeleteDB.settings.silentMode == nil then MondDeleteDB.settings.silentMode = false end

    -- Profiles
    MondDeleteDB.profiles = MondDeleteDB.profiles or {}
    MondDeleteDB.profile = MondDeleteDB.profile or self:GetCharProfileName()

    -- one-time legacy migration (old layout had top-level items/stats/audit)
    if not MondDeleteDB._profilesMigrated and type(MondDeleteDB.items) == "table" and next(MondDeleteDB.profiles) == nil then
        local prName = MondDeleteDB.profile
        MondDeleteDB.profiles[prName] = {
            items = MondDeleteDB.items,
            stats = (type(MondDeleteDB.stats) == "table" and MondDeleteDB.stats) or { total=0, itemCounts={}, history={} },
            audit = (type(MondDeleteDB.audit) == "table" and MondDeleteDB.audit) or { total=0, itemCounts={}, history={} },
        }
        MondDeleteDB._profilesMigrated = true
    end

    self:EnsureProfile(MondDeleteDB.profile)
    self:SyncActivePointers()
    self:InitLocale()

    -- fallback to English if unsupported saved lang
    local l = MondDeleteDB.settings.lang
    if not self.translations or not self.translations[l] then
        MondDeleteDB.settings.lang = "enUS"
    end
end

function Pro:GetUILocale()
    self:EnsureDB()
    local sel = MondDeleteDB.settings and MondDeleteDB.settings.lang
    if not sel or sel == "" then sel = "enUS" end
    if not self.translations or not self.translations[sel] then sel = "enUS" end
    return sel
end

function Pro:L(key)
    self:InitLocale()
    local loc = self:GetUILocale()
    local t = self.translations[loc] or self.translations.enUS
    return (t and t[key]) or (self.translations.enUS and self.translations.enUS[key]) or key
end

-------------------------------------------------
-- Profiles
-------------------------------------------------
function Pro:GetCharProfileName()
    local n = (UnitName and UnitName("player")) or "Player"
    return n
end

function Pro:EnsureProfile(name)
    MondDeleteDB.profiles = MondDeleteDB.profiles or {}
    if not MondDeleteDB.profiles[name] then
        MondDeleteDB.profiles[name] = {
            items = {},
            stats = { total = 0, itemCounts = {}, history = {} },
            audit = { total = 0, itemCounts = {}, history = {} },
        }
    else
        local pr = MondDeleteDB.profiles[name]
        pr.items = pr.items or {}
        pr.stats = pr.stats or { total = 0, itemCounts = {}, history = {} }
        pr.audit = pr.audit or { total = 0, itemCounts = {}, history = {} }
        pr.stats.total = pr.stats.total or 0
        pr.stats.itemCounts = pr.stats.itemCounts or {}
        pr.stats.history = pr.stats.history or {}
        pr.audit.total = pr.audit.total or 0
        pr.audit.itemCounts = pr.audit.itemCounts or {}
        pr.audit.history = pr.audit.history or {}
    end
end

function Pro:GetProfileList()
    self:EnsureDB()
    local t = {}
    for name in pairs(MondDeleteDB.profiles or {}) do
        table.insert(t, name)
    end
    table.sort(t, function(a,b) return string.lower(a) < string.lower(b) end)
    return t
end

function Pro:SyncActivePointers()
    if not MondDeleteDB then return end
    local name = MondDeleteDB.profile or self:GetCharProfileName()
    self:EnsureProfile(name)
    local pr = MondDeleteDB.profiles[name]

    MondDeleteDB.items = pr.items
    MondDeleteDB.stats = pr.stats
    MondDeleteDB.audit = pr.audit
end

function Pro:SetProfile(name)
    self:EnsureDB()
    name = MD_Trim(name)
    if name == "" then return end

    self:EnsureProfile(name)
    MondDeleteDB.profile = name
    self:SyncActivePointers()

    if not MondDeleteDB.settings.silentMode then
        MD_Chat(string.format("|cff00ff00[MondDelete]|r " .. self:L("SET_PROFILE_CHANGED"), name))
    end
    self:RefreshUI(false)
end

-------------------------------------------------
-- Reset stats (wipe tables, do not replace)
-------------------------------------------------
function Pro:ResetAudit()
    self:EnsureDB()

    local pr = MondDeleteDB.profiles[MondDeleteDB.profile]
    if not pr then return end
    pr.audit = pr.audit or { total=0, itemCounts={}, history={} }

    pr.audit.total = 0
    pr.audit.itemCounts = pr.audit.itemCounts or {}
    pr.audit.history = pr.audit.history or {}
    MD_WipeTable(pr.audit.itemCounts)
    MD_WipeTable(pr.audit.history)

    -- session
    self._session = { total=0, itemCounts={}, history={} }

    self:SyncActivePointers()
    self:RefreshUI(false)
end

-------------------------------------------------
-- Tab titles update (best-effort)
-------------------------------------------------
function Pro:UpdateTabTitles()
    if not MondDelete then return end

    local map = {
        { "TAB_BAGS",  1 },
        { "TAB_ITEMS", 2 },
        { "TAB_STATS", 3 },
        { "TAB_SETTINGS", 4 },
        { "TAB_ABOUT", 5 },
    }

    for _, v in ipairs(map) do
        local key, idx = v[1], v[2]
        local txt = self:L(key)

        local btn =
            _G["MondDeleteTab"..idx] or
            _G["MondDelete_Tab"..idx] or
            _G["MondDeleteTabButton"..idx] or
            _G["MondDelete_TabButton"..idx] or
            (MondDelete.tabs and MondDelete.tabs[idx] and MondDelete.tabs[idx].button)

        if btn then
            if btn.SetText then
                btn:SetText(txt)
            elseif btn.text and btn.text.SetText then
                btn.text:SetText(txt)
            elseif btn.GetFontString and btn:GetFontString() then
                btn:GetFontString():SetText(txt)
            end
        end
    end
end

-------------------------------------------------
-- Live UI refresh (no tab switching needed)
-------------------------------------------------
function Pro:RefreshUI(updateTabs)
    if updateTabs then
        self:UpdateTabTitles()
    end

    if self.ItemsPanel and self.ItemsPanel:IsShown() and self.ItemsRefresh then
        self.ItemsRefresh(self.ItemsPanel, false)
    end
    if self.StatsPanel and self.StatsPanel:IsShown() and self.StatsRefresh then
        self.StatsRefresh(self.StatsPanel, false)
    end
    if self.SettingsPanel and self.SettingsPanel:IsShown() and self.SettingsRefresh then
        self.SettingsRefresh(self.SettingsPanel)
    end
    if self.AboutPanel and self.AboutPanel:IsShown() and self.AboutRefresh then
        self.AboutRefresh(self.AboutPanel)
    end
end

-------------------------------------------------
-- Language setter
-------------------------------------------------
function Pro:SetLanguage(lang, langText)
    self:EnsureDB()
    if not lang or lang == "" then return end
    if not self.translations[lang] then lang = "enUS" end
    MondDeleteDB.settings.lang = lang

    if not MondDeleteDB.settings.silentMode then
        MD_Chat(string.format("|cff00ff00[MondDelete]|r " .. self:L("LANG_CHANGED"), langText or lang))
    end
    self:RefreshUI(true)
end

-------------------------------------------------
-- Add item to list (Alt + Right Click) + message (NO duplicates)
-------------------------------------------------
function Pro:AddItemToList(itemID, link)
    self:EnsureDB()
    if not itemID then return end

    -- prevent double-fire from hooks
    local now = MD_Now()
    self._recentAdd = self._recentAdd or {}
    local last = self._recentAdd[itemID]
    if last and (now - last) < 0.5 then
        return
    end
    self._recentAdd[itemID] = now

    local exists = MondDeleteDB.items[itemID] or MondDeleteDB.items[tostring(itemID)]
    if exists then
        -- as requested: if already exists -> say nothing
        return
    end

    MondDeleteDB.items[itemID] = true
    local label = MD_MakeItemLink(itemID, link)
    if not MondDeleteDB.settings.silentMode then
        MD_Chat(string.format("|cff00ff00[MondDelete]|r " .. self:L("ITEMS_ADDED"), label))
    end

    self:RefreshUI(false)
end

function Pro:InstallAddItemHook()
    if self._addHookInstalled then return end
    self._addHookInstalled = true

    if hooksecurefunc and type(ContainerFrameItemButton_OnModifiedClick) == "function" then
        hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(btn, button)
            if button ~= "RightButton" then return end
            if not IsAltKeyDown or not IsAltKeyDown() then return end

            local parent = btn and btn:GetParent()
            local bag = parent and parent.GetID and parent:GetID()
            local slot = btn and btn.GetID and btn:GetID()
            if bag == nil or slot == nil then return end

            local link = GetContainerItemLink and GetContainerItemLink(bag, slot)
            local itemID = MD_ParseItemIDFromLink(link)
            if not itemID then return end

            Pro:AddItemToList(itemID, link)
        end)
    end
end

-------------------------------------------------
-- Delete list text (for confirm-start popup)
-------------------------------------------------
function Pro:BuildDeleteListText(maxLines)
    self:EnsureDB()
    maxLines = maxLines or 12

    local ids = {}
    for k in pairs(MondDeleteDB.items or {}) do
        table.insert(ids, k)
    end
    table.sort(ids, function(a,b) return tostring(a) < tostring(b) end)

    if #ids == 0 then return "(empty)" end

    local lines = {}
    for i = 1, math.min(#ids, maxLines) do
        local id = ids[i]
        table.insert(lines, "• " .. MD_MakeItemLink(tonumber(id) or id))
    end
    if #ids > maxLines then
        table.insert(lines, "• ... +" .. (#ids - maxLines) .. " more")
    end
    return table.concat(lines, "\n")
end

-------------------------------------------------
-- Stats / history printing (localized, clickable links)
-------------------------------------------------
function Pro:PrintTop(n)
    self:EnsureDB()
    n = n or 10

    local audit = MondDeleteDB.audit or { total=0, itemCounts={}, history={} }
    local tmp = {}
    for id, c in pairs(audit.itemCounts or {}) do
        local count = tonumber(c) or 0
        if count > 0 then
            table.insert(tmp, { id = tonumber(id) or id, c = count })
        end
    end

    table.sort(tmp, function(a, b)
        if a.c ~= b.c then return a.c > b.c end
        return tostring(a.id) < tostring(b.id)
    end)

    MD_Chat("|cff00ff00[MondDelete]|r " .. string.format(self:L("MSG_TOP_TITLE"), tonumber(audit.total) or 0))
    local limit = math.min(n, #tmp)
    for i = 1, limit do
        local d = tmp[i]
        MD_Chat("  " .. d.c .. "x " .. MD_MakeItemLink(d.id))
    end
end

function Pro:PrintHistory(n)
    self:EnsureDB()
    n = n or 20

    local audit = MondDeleteDB.audit or { total=0, itemCounts={}, history={} }
    local h = audit.history or {}
    if #h == 0 then
        MD_Chat("|cff00ff00[MondDelete]|r " .. self:L("MSG_HISTORY_EMPTY"))
        return
    end

    MD_Chat("|cff00ff00[MondDelete]|r " .. string.format(self:L("MSG_HISTORY_TITLE"), math.min(n, #h)))
    local start = math.max(1, #h - n + 1)
    for i = start, #h do
        local e = h[i]
        local ts = e.ts or ""
        local label = MD_MakeItemLink(e.id, e.link)
        local line = ""
        if ts ~= "" then
            line = line .. "|cff999999[" .. ts .. "]|r "
        end
        line = line .. (tonumber(e.c) or 1) .. "x " .. label
        MD_Chat("  " .. line)
    end
end

-------------------------------------------------
-- Deletion tracking (NO duplicates, clickable link, respects enabled/chatLog)
-------------------------------------------------
function Pro:RecordDeletion(itemID, count, link)
    self:EnsureDB()

    local settings = MondDeleteDB.settings or {}
    local enabled = settings.enabled
    if enabled == nil then enabled = true end
    if not enabled then
        return
    end

    local idNum = tonumber(itemID) or itemID
    local c = tonumber(count) or 1
    if c < 1 then c = 1 end

    -- anti-duplicate (same item within short window)
    local now = MD_Now()
    self._recentDel = self._recentDel or {}
    local k1 = tostring(idNum)
    local k2 = tostring(idNum) .. ":" .. tostring(c)
    if (self._recentDel[k1] and (now - self._recentDel[k1]) < 0.75) or
       (self._recentDel[k2] and (now - self._recentDel[k2]) < 0.75) then
        return
    end
    self._recentDel[k1] = now
    self._recentDel[k2] = now

    -- db counters
    local audit = MondDeleteDB.audit or { total=0, itemCounts={}, history={} }
    MondDeleteDB.audit = audit

    audit.total = (tonumber(audit.total) or 0) + c
    audit.itemCounts = audit.itemCounts or {}
    audit.itemCounts[idNum] = (tonumber(audit.itemCounts[idNum]) or 0) + c

    audit.history = audit.history or {}
    local ts = MD_TimeStamp()
    table.insert(audit.history, { id = idNum, c = c, link = link, ts = ts })
    if #audit.history > 200 then table.remove(audit.history, 1) end

    -- session counters for Stats tab
    self._session = self._session or { total=0, itemCounts={}, history={} }
    self._session.total = (tonumber(self._session.total) or 0) + c
    self._session.itemCounts = self._session.itemCounts or {}
    self._session.itemCounts[idNum] = (tonumber(self._session.itemCounts[idNum]) or 0) + c
    self._session.history = self._session.history or {}
    table.insert(self._session.history, { id=idNum, c=c, link=link, ts=ts })
    if #self._session.history > 200 then table.remove(self._session.history, 1) end

   -- optional chat log (ONE line only, no spam)
if settings.chatLog and not settings.silentMode then
    self._chatDelGuard = self._chatDelGuard or {}

    local now2 = MD_Now()
    local key2 = tostring(idNum) .. ":" .. tostring(c)

    local last2 = self._chatDelGuard[key2]
    if not last2 or (now2 - last2) > 1.5 then
        self._chatDelGuard[key2] = now2

        local label = MD_MakeItemLink(idNum, link)
        MD_Chat("|cff00ff00[MondDelete]|r " .. self:L("MSG_DELETED") .. " " .. c .. "x " .. label)
    end

    -- cleanup
    for kk, tt in pairs(self._chatDelGuard) do
        if (now2 - tt) > 6.0 then
            self._chatDelGuard[kk] = nil
        end
    end
end


    self:RefreshUI(false)
end

-------------------------------------------------
-- Chat dedup: keep ONLY linked MondDelete lines
-- (kills spam lines without |Hitem: )
-------------------------------------------------
function Pro:InstallChatDedup()
    if self._chatDedupInstalled then return end
    self._chatDedupInstalled = true

    local f = DEFAULT_CHAT_FRAME
    if not f or type(f.AddMessage) ~= "function" then return end

    if not self._origChatAddMessage then
        self._origChatAddMessage = f.AddMessage
    end

    self._chatSeen = self._chatSeen or {}

    f.AddMessage = function(frame, msg, ...)
        if type(msg) == "string" and msg:find("%[MondDelete%]") and msg:find("Deleted") then
            -- 1) If no clickable item link -> suppress completely
            if not msg:find("|Hitem:") then
                return
            end

            -- 2) Dedup even linked lines (same message within 1.2 sec)
            local now = (GetTime and GetTime()) or 0
            local key = msg:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
            local last = self._chatSeen[key]
            if last and (now - last) < 1.2 then
                return
            end
            self._chatSeen[key] = now

            -- cleanup
            for k, t in pairs(self._chatSeen) do
                if (now - t) > 6.0 then
                    self._chatSeen[k] = nil
                end
            end
        end

        return self._origChatAddMessage(frame, msg, ...)
    end
end





-------------------------------------------------
-- Hooks (Alt+RightClick add + deletion confirm / enabled check)
-------------------------------------------------
function Pro:InstallHooks()
    if self._hooksInstalled then return end
    self._hooksInstalled = true

    self:EnsureDB()
    self:InstallAddItemHook()
    self:InstallChatDedup()

    -- store originals once
    self._origPickup = self._origPickup or PickupContainerItem
    self._origDeleteCursor = self._origDeleteCursor or DeleteCursorItem

    PickupContainerItem = function(bag, slot)
        local link = (GetContainerItemLink and GetContainerItemLink(bag, slot)) or nil
        local itemID = MD_ParseItemIDFromLink(link)
        local count = 1

        if GetContainerItemInfo then
            local _, itemCount = GetContainerItemInfo(bag, slot)
            count = itemCount or 1
        end

        if itemID then
            Pro._lastPickup = { bag=bag, slot=slot, itemID=itemID, count=count, link=link }
        else
            Pro._lastPickup = nil
        end

        return Pro._origPickup(bag, slot)
    end

    local function isInDeleteList(id)
        if not id then return false end
        return MondDeleteDB.items[id] or MondDeleteDB.items[tostring(id)]
    end

    local function returnItemToSlot()
        local lp = Pro._lastPickup
        if lp and lp.bag ~= nil and lp.slot ~= nil then
            Pro._origPickup(lp.bag, lp.slot)
        else
            if ClearCursor then ClearCursor() end
        end
    end

    local POP_EACH = "MONDDELETE_CONFIRM_EACH_ITEM"
    StaticPopupDialogs[POP_EACH] = StaticPopupDialogs[POP_EACH] or {
        text = "",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            local info = Pro._pendingEach
            Pro._pendingEach = nil
            Pro._pendingLocked = nil

            Pro._origDeleteCursor()

            if info and info.itemID then
                Pro:RecordDeletion(info.itemID, info.count or 1, info.link)
            end
        end,
        OnCancel = function()
            Pro._pendingEach = nil
            Pro._pendingLocked = nil
            returnItemToSlot()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    DeleteCursorItem = function()
        Pro:EnsureDB()

        local ctype, id, link = nil, nil, nil
        if GetCursorInfo then
            ctype, id, link = GetCursorInfo()
        end
        if ctype ~= "item" then
            return Pro._origDeleteCursor()
        end

        local itemID = tonumber(id) or id
        if not isInDeleteList(itemID) then
            return Pro._origDeleteCursor()
        end

        -- count from last pickup if possible
        local count = 1
        local lp = Pro._lastPickup
        if lp and lp.itemID and tonumber(lp.itemID) == tonumber(itemID) then
            count = lp.count or 1
            link = link or lp.link
        end

        local enabled = MondDeleteDB.settings.enabled
        if enabled == nil then enabled = true end
        if not enabled then
            returnItemToSlot()
            local now = MD_Now()
            if not Pro._disabledWarn or (now - Pro._disabledWarn) > 2 then
                Pro._disabledWarn = now
                if not MondDeleteDB.settings.silentMode then
                    MD_Chat(Pro:L("MSG_DISABLED"))
                end
            end
            return
        end

        if MondDeleteDB.settings.confirmEach then
            if Pro._pendingLocked then return end
            Pro._pendingLocked = true
            Pro._pendingEach = { itemID=itemID, count=count, link=link }

            local label = MD_MakeItemLink(itemID, link)
            StaticPopupDialogs[POP_EACH].text = string.format(Pro:L("POP_DELETE_TEXT"), count, label)
            StaticPopupDialogs[POP_EACH].button1 = Pro:L("COMMON_YES")
            StaticPopupDialogs[POP_EACH].button2 = Pro:L("COMMON_NO")

            StaticPopup_Show(POP_EACH)
            return
        end

        Pro._origDeleteCursor()
        Pro:RecordDeletion(itemID, count, link)
    end
end

-- Install immediately (so hooks exist even before opening Settings tab)
Pro:InstallHooks()

-------------------------------------------------
-- SETTINGS TAB UI
-------------------------------------------------
MondDelete:RegisterTab(4, "Settings",

-- BUILD
function(p)
    Pro:EnsureDB()
    Pro.SettingsPanel = p

    -- Title / description
    if not p.title then
        p.title = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        p.title:SetPoint("TOPLEFT", 10, -6)

        p.desc = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.desc:SetPoint("TOPLEFT", p.title, "BOTTOMLEFT", 0, -6)
        p.desc:SetWidth(340)
        p.desc:SetJustifyH("LEFT")
    end

    -- Profile dropdown
    if not p.profileLabel then
        p.profileLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        p.profileLabel:SetPoint("TOPLEFT", 10, -46)

        p.profileDD = CreateFrame("Frame", "MondDelete_ProfileDropDown", p, "UIDropDownMenuTemplate")
        p.profileDD:SetPoint("TOPLEFT", 80, -52)
        UIDropDownMenu_SetWidth(p.profileDD, 160)
        UIDropDownMenu_SetButtonWidth(p.profileDD, 160)
    end

    UIDropDownMenu_Initialize(p.profileDD, function(self, level)
        local current = MondDeleteDB.profile
        local list = Pro:GetProfileList()

        for _, name in ipairs(list) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.value = name
            info.checked = (name == current)
            info.func = function()
                Pro:SetProfile(name)
                UIDropDownMenu_SetSelectedValue(p.profileDD, name)
                UIDropDownMenu_SetText(p.profileDD, name)
            end
            UIDropDownMenu_AddButton(info, level)
        end

        local info = UIDropDownMenu_CreateInfo()
        info.text = Pro:L("SET_PROFILE_NEW")
        info.notCheckable = true
        info.func = function()
            local key = "MONDDELETE_NEW_PROFILE"
            StaticPopupDialogs[key] = StaticPopupDialogs[key] or {
                text = "",
                button1 = "",
                button2 = "",
                hasEditBox = true,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                OnShow = function(self)
                    self.editBox:SetText("")
                    self.editBox:SetFocus()
                end,
                OnAccept = function(self)
                    local nm = MD_Trim(self.editBox:GetText())
                    if nm ~= "" then Pro:SetProfile(nm) end
                end,
                EditBoxOnEnterPressed = function(self)
                    local parent = self:GetParent()
                    local nm = MD_Trim(self:GetText())
                    if nm ~= "" then
                        Pro:SetProfile(nm)
                        parent:Hide()
                    end
                end,
            }
            StaticPopupDialogs[key].text = Pro:L("SET_PROFILE_NEW_PROMPT")
            StaticPopupDialogs[key].button1 = Pro:L("COMMON_YES")
            StaticPopupDialogs[key].button2 = Pro:L("COMMON_NO")
            StaticPopup_Show(key)
        end
        UIDropDownMenu_AddButton(info, level)
    end)

    -- Language dropdown (Top-5)
    if not p.langLabel then
        p.langLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        p.langLabel:SetPoint("TOPLEFT", 10, -78)

        p.langDD = CreateFrame("Frame", "MondDelete_LangDropDown", p, "UIDropDownMenuTemplate")
        p.langDD:SetPoint("TOPLEFT", 80, -84)
        UIDropDownMenu_SetWidth(p.langDD, 160)
        UIDropDownMenu_SetButtonWidth(p.langDD, 160)
    end

    local langOptions = {
        { value="enUS", text="English" },
        { value="frFR", text="Français" },
        { value="deDE", text="Deutsch" },
        { value="esES", text="Español" },
        { value="itIT", text="Italiano" },
    }

    UIDropDownMenu_Initialize(p.langDD, function(self, level)
        local current = MondDeleteDB.settings.lang or "enUS"
        for _, o in ipairs(langOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = o.text
            info.value = o.value
            info.checked = (o.value == current)
            info.func = function()
                Pro:SetLanguage(o.value, o.text)
                UIDropDownMenu_SetSelectedValue(p.langDD, o.value)
                UIDropDownMenu_SetText(p.langDD, o.text)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Status + Start/Stop (moved a bit lower to avoid overlap)
    if not p.statusLabel then
        p.statusLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        p.statusLabel:SetPoint("TOPLEFT", 10, -124)

        p.statusValue = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        p.statusValue:SetPoint("LEFT", p.statusLabel, "RIGHT", 6, 0)

        p.toggleBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        p.toggleBtn:SetSize(90, 18)
        p.toggleBtn:SetPoint("TOPRIGHT", -12, -120)

        p.toggleBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(Pro:L("SET_TIP_START"), 1,1,1, true)
            GameTooltip:Show()
        end)
        p.toggleBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        p.toggleBtn:SetScript("OnClick", function()
            Pro:EnsureDB()

            local enabled = MondDeleteDB.settings.enabled
            if enabled == nil then enabled = true end

            if enabled then
                MondDeleteDB.settings.enabled = false
                Pro:RefreshUI(false)
                return
            end

            local function enableNow()
                MondDeleteDB.settings.enabled = true
                Pro:RefreshUI(false)
            end

            if MondDeleteDB.settings.confirmStart then
                local key = "MONDDELETE_CONFIRM_START_ENABLE"
                StaticPopupDialogs[key] = StaticPopupDialogs[key] or {
                    text = "",
                    button1 = "",
                    button2 = "",
                    OnAccept = function() enableNow() end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                }

                local listText = Pro:BuildDeleteListText(12)
                StaticPopupDialogs[key].text = string.format(Pro:L("POP_CONFIRM_TEXT"), MondDeleteDB.profile, listText)
                StaticPopupDialogs[key].button1 = Pro:L("COMMON_YES")
                StaticPopupDialogs[key].button2 = Pro:L("COMMON_NO")
                StaticPopup_Show(key)
            else
                enableNow()
            end
        end)
    end

    -- Checkboxes (no auto-loot option)
    p.cbs = p.cbs or {}
    local function addCB(idx, y, key, tipKey)
        local slot = p.cbs[idx]
        if not slot then
            local cb = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
            cb:SetPoint("TOPLEFT", 10, y)

            cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 1)

            cb:SetScript("OnEnter", function(self)
                local tip = tipKey and Pro:L(tipKey) or ""
                if tip ~= "" then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(self.text:GetText() or "", 1,1,1, true)
                    GameTooltip:AddLine(tip, 0.7,0.7,0.7, true)
                    GameTooltip:Show()
                end
            end)
            cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
            cb:SetScript("OnClick", function(self)
                MondDeleteDB.settings[key] = self:GetChecked() and true or false
                Pro:RefreshUI(false)
            end)
            p.cbs[idx] = { cb = cb, key = key, tipKey = tipKey }
        else
            slot.key = key
            slot.tipKey = tipKey
        end
    end

    addCB(1, -150, "chatLog", "SET_TIP_CHAT")
    addCB(2, -176, "confirmStart", "SET_TIP_STARTCONF")
    addCB(3, -202, "confirmEach", "SET_TIP_CONFIRM_EACH")
    addCB(4, -228, "silentMode", "SET_TIP_SILENTMODE")

    Pro.SettingsRefresh(p)
end,

-- REFRESH
function(p)
    Pro:EnsureDB()
    Pro.SettingsPanel = p
    if Pro.SettingsRefresh then Pro.SettingsRefresh(p) end
end)

-------------------------------------------------
-- Settings refresh (called live on toggles & language changes)
-------------------------------------------------
function Pro.SettingsRefresh(p)
    if not p then return end
    Pro:EnsureDB()

    if p.title then p.title:SetText(Pro:L("SET_TITLE")) end
    if p.desc then p.desc:SetText(Pro:L("SET_DESC")) end
    if p.profileLabel then p.profileLabel:SetText(Pro:L("SET_PROFILE")) end
    if p.langLabel then p.langLabel:SetText(Pro:L("SET_LANGUAGE")) end
    if p.statusLabel then p.statusLabel:SetText(Pro:L("SET_STATUS")) end

    -- dropdown texts
    if p.profileDD then
        UIDropDownMenu_SetSelectedValue(p.profileDD, MondDeleteDB.profile)
        UIDropDownMenu_SetText(p.profileDD, MondDeleteDB.profile)
    end

    if p.langDD then
        local langNow = MondDeleteDB.settings.lang or "enUS"
        local txt = "English"
        if langNow == "frFR" then txt = "Français"
        elseif langNow == "deDE" then txt = "Deutsch"
        elseif langNow == "esES" then txt = "Español"
        elseif langNow == "itIT" then txt = "Italiano"
        end
        UIDropDownMenu_SetSelectedValue(p.langDD, langNow)
        UIDropDownMenu_SetText(p.langDD, txt)
    end

    -- enabled status / button
    local enabled = MondDeleteDB.settings.enabled
    if enabled == nil then enabled = true end
    if p.statusValue then
        p.statusValue:SetText(enabled and ("|cff00ff00" .. Pro:L("SET_ON") .. "|r") or ("|cffff0000" .. Pro:L("SET_OFF") .. "|r"))
    end
    if p.toggleBtn then
        p.toggleBtn:SetText(enabled and Pro:L("SET_STOP") or Pro:L("SET_START"))
    end

    -- checkbox texts + states
    if p.cbs then
        -- order: chatLog, confirmStart, confirmEach, silentMode
        local map = {
            [1] = { textKey="SET_CHATLOG", settingKey="chatLog" },
            [2] = { textKey="SET_CONFIRM_START", settingKey="confirmStart" },
            [3] = { textKey="SET_CONFIRM_EACH", settingKey="confirmEach" },
            [4] = { textKey="SET_SILENTMODE", settingKey="silentMode" },
        }
        for idx, v in pairs(map) do
            local slot = p.cbs[idx]
            if slot and slot.cb and slot.cb.text then
                slot.cb.text:SetText(Pro:L(v.textKey))
                slot.cb:SetChecked(MondDeleteDB.settings[v.settingKey] and true or false)
            end
        end
    end
end

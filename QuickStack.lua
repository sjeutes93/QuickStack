-- QuickStack: buys a configurable amount at a vendor with Modifier + Left-click,
-- tracks vendor prices, and supports per-character profiles.

local ADDON = "QuickStack"
local MAX_SLIDER = 20           -- slider range 1..20
local MAX_AMOUNT = 1000         -- upper limit when typing an amount
local MAX_VENDORS_PER_ITEM = 8  -- price history kept per item
local BUG_URL = "https://github.com/sjeutes93/QuickStack/issues"
local DOWNLOAD_URL = "https://www.curseforge.com/wow/addons/quickstack" -- shown in the update message
local PREFIX = "QuickStack"     -- addon message prefix for version checks

----------------------------------------------------------------------
-- Localization (English default; de, fr, es, ru)
----------------------------------------------------------------------
local en = {
    ITEMS = "Items", PRICES = "Prices", PROFILES = "Profiles", SETTINGS = "Settings", BUGREPORT = "Bug Report",
    HINT_ITEMS = "Alt-click an item at a vendor to add it automatically, or drag an item from your bags into the box below. 'Per click' buys this many, 'Top up to' fills your bags up to this many.",
    DROP = "Drop an item here to add it",
    NO_ITEMS = "No items yet. Alt + Left-click an item at a vendor or drop one above.",
    HINT_PRICES = "Prices are saved automatically whenever you open a vendor (price per item). Differences between vendors can come from reputation discounts.",
    ONLY_MINE = "Only my items",
    NO_PRICES = "No prices recorded yet. Visit a vendor and they appear here automatically.",
    MODIFIER = "Modifier key",
    MODIFIER_NOTE = "Alt is recommended. Ctrl opens the dressing room and Shift opens the quantity prompt.",
    AUTO_ADD = "Add items automatically when bought",
    SHOW_PANEL = "Show price table at vendors",
    SHOW_TOOLTIP = "Show prices in item tooltips",
    SHOW_MINIMAP = "Show minimap button",
    RESET_MINIMAP = "Reset minimap button position",
    CLEAR_PRICES = "Clear price data",
    PRICES_CLEARED = "Price data cleared.",
    UNLISTED = "Unlisted items: a full stack (max. 20) is bought on the first click.",
    CONFIRM_LABEL = "Ask before spending more than (gold, 0 = off):",
    DESCRIBE = "Describe the problem",
    CREATE_REPORT = "Create report",
    BUG_HINT = "Addons cannot send data out of the game. Press Ctrl+C to copy the report, then post it in the comments on the QuickStack project page.",
    REPORT_PAGE = "Report page (Ctrl+C to copy):",
    MM_LEFT = "Left-click: open menu",
    MM_DRAG = "Drag: move button",
    NOT_ENOUGH = "Not enough gold or vendor stock for %s.",
    MOD_SET = "Modifier set to %s + Left-click.",
    PANEL_TITLE = "QuickStack - Prices",
    TT_TITLE = "QuickStack prices",
    NO_OTHER = "No other vendor known yet",
    CHEAPER = "|cffff6060+%d%% here|r - cheaper at %s: %s (%s). Saves %s",
    BEST = "|cff40ff40Best price|r (%d%% cheaper than %s)",
    SAME = "|cff40ff40Same price|r as elsewhere",
    PER_CLICK = "Per click", TOP_UP = "Top up to",
    IN_BAGS = "In bags: %d",
    HAVE_ENOUGH = "You already have %d x %s.",
    CONFIRM = "Buy %d x %s for %s?",
    OK = "OK",
    AGE_D = "%dd ago", AGE_H = "%dh ago", AGE_NOW = "<1h ago",
    PROFILE_FOR = "Profile for this character:",
    NEW_NAME = "New profile name:",
    CREATE = "Create", DUPLICATE = "Duplicate", DELETE_PROFILE = "Delete profile",
    EXPORT_LABEL = "Export / import your item list (copy with Ctrl+C):",
    EXPORT = "Export", IMPORT = "Import",
    IMPORTED = "Imported %d items.",
    IMPORT_FAIL = "Import failed: no valid data.",
    PROFILE_CREATED = "Profile \"%s\" created.",
    PROFILE_EXISTS = "A profile with this name already exists.",
    BINDING = "Open QuickStack menu",
    NOTIFY_UPDATE = "Notify me about new versions",
    UPDATE_AVAILABLE = "A new version is available: %s (you have %s).",
    UPDATE_LINK = "Download: %s",
    UPDATE_BANNER = "New version %s available",
}

local tr = {}
tr.deDE = {
    ITEMS = "Items", PRICES = "Preise", PROFILES = "Profile", SETTINGS = "Einstellungen", BUGREPORT = "Bug melden",
    HINT_ITEMS = "Alt-Klick auf einen Gegenstand beim Händler fügt ihn automatisch hinzu, oder zieh einen Gegenstand aus deinen Taschen in das Feld unten. „Pro Klick“ kauft diese Menge, „Auffüllen auf“ füllt deine Taschen bis zu dieser Menge.",
    DROP = "Gegenstand hier ablegen, um ihn hinzuzufügen",
    NO_ITEMS = "Noch keine Items. Alt + Linksklick beim Händler oder oben einen Gegenstand ablegen.",
    HINT_PRICES = "Preise werden automatisch gespeichert, sobald du einen Händler öffnest (Preis pro Stück). Unterschiede zwischen Händlern können von Rufrabatten kommen.",
    ONLY_MINE = "Nur meine Items",
    NO_PRICES = "Noch keine Preise gespeichert. Besuche einen Händler, dann erscheinen sie hier automatisch.",
    MODIFIER = "Modifier-Taste",
    MODIFIER_NOTE = "Alt wird empfohlen. Strg öffnet die Anprobe und Umschalt die Mengenabfrage.",
    AUTO_ADD = "Items beim Kauf automatisch hinzufügen",
    SHOW_PANEL = "Preistabelle beim Händler anzeigen",
    SHOW_TOOLTIP = "Preise in Item-Tooltips anzeigen",
    SHOW_MINIMAP = "Minimap-Button anzeigen",
    RESET_MINIMAP = "Minimap-Button zurücksetzen",
    CLEAR_PRICES = "Preisdaten löschen",
    PRICES_CLEARED = "Preisdaten gelöscht.",
    UNLISTED = "Items ohne Eintrag: Beim ersten Klick wird ein voller Stack (max. 20) gekauft.",
    CONFIRM_LABEL = "Nachfragen ab (Gold, 0 = aus):",
    DESCRIBE = "Beschreibe das Problem",
    CREATE_REPORT = "Bericht erstellen",
    BUG_HINT = "Addons können keine Daten aus dem Spiel senden. Drücke Strg+C, um den Bericht zu kopieren, und poste ihn in den Kommentaren auf der QuickStack-Projektseite.",
    REPORT_PAGE = "Meldeseite (Strg+C zum Kopieren):",
    MM_LEFT = "Linksklick: Menü öffnen", MM_DRAG = "Ziehen: Button verschieben",
    NOT_ENOUGH = "Nicht genug Gold oder Händlerbestand für %s.",
    MOD_SET = "Taste gesetzt auf %s + Linksklick.",
    PANEL_TITLE = "QuickStack - Preise", TT_TITLE = "QuickStack-Preise",
    NO_OTHER = "Noch kein anderer Händler bekannt",
    CHEAPER = "|cffff6060+%d%% hier|r - günstiger in %s: %s (%s). Spart %s",
    BEST = "|cff40ff40Bester Preis|r (%d%% günstiger als %s)",
    SAME = "|cff40ff40Gleicher Preis|r wie anderswo",
    PER_CLICK = "Pro Klick", TOP_UP = "Auffüllen auf",
    IN_BAGS = "In Taschen: %d",
    HAVE_ENOUGH = "Du hast bereits %d x %s.",
    CONFIRM = "%d x %s für %s kaufen?",
    AGE_D = "vor %d T.", AGE_H = "vor %d Std.", AGE_NOW = "vor <1 Std.",
    PROFILE_FOR = "Profil für diesen Charakter:",
    NEW_NAME = "Name des neuen Profils:",
    CREATE = "Erstellen", DUPLICATE = "Duplizieren", DELETE_PROFILE = "Profil löschen",
    EXPORT_LABEL = "Item-Liste exportieren / importieren (mit Strg+C kopieren):",
    EXPORT = "Exportieren", IMPORT = "Importieren",
    IMPORTED = "%d Items importiert.",
    IMPORT_FAIL = "Import fehlgeschlagen: keine gültigen Daten.",
    PROFILE_CREATED = "Profil „%s“ erstellt.",
    PROFILE_EXISTS = "Ein Profil mit diesem Namen existiert bereits.",
    BINDING = "QuickStack-Menü öffnen",
    NOTIFY_UPDATE = "Über neue Versionen benachrichtigen",
    UPDATE_AVAILABLE = "Eine neue Version ist verfügbar: %s (du hast %s).",
    UPDATE_LINK = "Download: %s",
    UPDATE_BANNER = "Neue Version %s verfügbar",
}
tr.frFR = {
    ITEMS = "Objets", PRICES = "Prix", PROFILES = "Profils", SETTINGS = "Options", BUGREPORT = "Signaler un bug",
    HINT_ITEMS = "Alt + clic sur un objet chez un marchand l'ajoute automatiquement, ou faites glisser un objet de vos sacs dans la zone ci-dessous. « Par clic » achète cette quantité, « Compléter à » remplit vos sacs jusqu'à cette quantité.",
    DROP = "Déposez un objet ici pour l'ajouter",
    NO_ITEMS = "Aucun objet. Alt + clic gauche chez un marchand ou déposez-en un ci-dessus.",
    HINT_PRICES = "Les prix sont enregistrés automatiquement à chaque ouverture d'un marchand (prix à l'unité). Les écarts peuvent venir de remises de réputation.",
    ONLY_MINE = "Mes objets uniquement",
    NO_PRICES = "Aucun prix enregistré. Visitez un marchand et ils apparaîtront ici.",
    MODIFIER = "Touche modificatrice",
    MODIFIER_NOTE = "Alt est recommandé. Ctrl ouvre la cabine d'essayage et Maj la fenêtre de quantité.",
    AUTO_ADD = "Ajouter automatiquement les objets achetés",
    SHOW_PANEL = "Afficher le tableau des prix chez les marchands",
    SHOW_TOOLTIP = "Afficher les prix dans les infobulles",
    SHOW_MINIMAP = "Afficher le bouton de la minicarte",
    RESET_MINIMAP = "Réinitialiser la position du bouton",
    CLEAR_PRICES = "Effacer les prix",
    PRICES_CLEARED = "Prix effacés.",
    UNLISTED = "Objets non listés : une pile complète (max. 20) est achetée au premier clic.",
    CONFIRM_LABEL = "Confirmer au-dessus de (or, 0 = désactivé) :",
    DESCRIBE = "Décrivez le problème",
    CREATE_REPORT = "Créer le rapport",
    BUG_HINT = "Les addons ne peuvent pas envoyer de données hors du jeu. Appuyez sur Ctrl+C pour copier le rapport, puis postez-le dans les commentaires de la page du projet QuickStack.",
    REPORT_PAGE = "Page de signalement (Ctrl+C pour copier) :",
    MM_LEFT = "Clic gauche : ouvrir le menu", MM_DRAG = "Glisser : déplacer le bouton",
    NOT_ENOUGH = "Pas assez d'or ou de stock chez le marchand pour %s.",
    MOD_SET = "Touche définie sur %s + clic gauche.",
    PANEL_TITLE = "QuickStack - Prix", TT_TITLE = "Prix QuickStack",
    NO_OTHER = "Aucun autre marchand connu",
    CHEAPER = "|cffff6060+%d%% ici|r - moins cher à %s : %s (%s). Économie : %s",
    BEST = "|cff40ff40Meilleur prix|r (%d%% moins cher que %s)",
    SAME = "|cff40ff40Même prix|r qu'ailleurs",
    PER_CLICK = "Par clic", TOP_UP = "Compléter à",
    IN_BAGS = "Dans les sacs : %d",
    HAVE_ENOUGH = "Vous avez déjà %d x %s.",
    CONFIRM = "Acheter %d x %s pour %s ?",
    AGE_D = "il y a %d j", AGE_H = "il y a %d h", AGE_NOW = "il y a <1 h",
    PROFILE_FOR = "Profil de ce personnage :",
    NEW_NAME = "Nom du nouveau profil :",
    CREATE = "Créer", DUPLICATE = "Dupliquer", DELETE_PROFILE = "Supprimer le profil",
    EXPORT_LABEL = "Exporter / importer votre liste (copier avec Ctrl+C) :",
    EXPORT = "Exporter", IMPORT = "Importer",
    IMPORTED = "%d objets importés.",
    IMPORT_FAIL = "Échec de l'import : données invalides.",
    PROFILE_CREATED = "Profil « %s » créé.",
    PROFILE_EXISTS = "Un profil portant ce nom existe déjà.",
    BINDING = "Ouvrir le menu QuickStack",
    NOTIFY_UPDATE = "M'avertir des nouvelles versions",
    UPDATE_AVAILABLE = "Une nouvelle version est disponible : %s (vous avez %s).",
    UPDATE_LINK = "Téléchargement : %s",
    UPDATE_BANNER = "Nouvelle version %s disponible",
}
tr.esES = {
    ITEMS = "Objetos", PRICES = "Precios", PROFILES = "Perfiles", SETTINGS = "Opciones", BUGREPORT = "Informar de un error",
    HINT_ITEMS = "Alt + clic en un objeto en un vendedor lo añade automáticamente, o arrastra un objeto de tus bolsas al cuadro de abajo. «Por clic» compra esa cantidad, «Rellenar hasta» llena tus bolsas hasta esa cantidad.",
    DROP = "Suelta un objeto aquí para añadirlo",
    NO_ITEMS = "Aún no hay objetos. Alt + clic izquierdo en un vendedor o suelta uno arriba.",
    HINT_PRICES = "Los precios se guardan automáticamente al abrir un vendedor (precio por unidad). Las diferencias pueden deberse a descuentos de reputación.",
    ONLY_MINE = "Solo mis objetos",
    NO_PRICES = "Aún no hay precios guardados. Visita un vendedor y aparecerán aquí.",
    MODIFIER = "Tecla modificadora",
    MODIFIER_NOTE = "Se recomienda Alt. Ctrl abre el probador y Mayús la ventana de cantidad.",
    AUTO_ADD = "Añadir objetos automáticamente al comprarlos",
    SHOW_PANEL = "Mostrar tabla de precios en los vendedores",
    SHOW_TOOLTIP = "Mostrar precios en los tooltips",
    SHOW_MINIMAP = "Mostrar botón del minimapa",
    RESET_MINIMAP = "Restablecer posición del botón",
    CLEAR_PRICES = "Borrar precios",
    PRICES_CLEARED = "Precios borrados.",
    UNLISTED = "Objetos sin lista: se compra una pila completa (máx. 20) en el primer clic.",
    CONFIRM_LABEL = "Preguntar al gastar más de (oro, 0 = no):",
    DESCRIBE = "Describe el problema",
    CREATE_REPORT = "Crear informe",
    BUG_HINT = "Los addons no pueden enviar datos fuera del juego. Pulsa Ctrl+C para copiar el informe y publícalo en los comentarios de la página de QuickStack.",
    REPORT_PAGE = "Página de informes (Ctrl+C para copiar):",
    MM_LEFT = "Clic izquierdo: abrir menú", MM_DRAG = "Arrastrar: mover botón",
    NOT_ENOUGH = "No hay suficiente oro o existencias del vendedor para %s.",
    MOD_SET = "Tecla establecida en %s + clic izquierdo.",
    PANEL_TITLE = "QuickStack - Precios", TT_TITLE = "Precios de QuickStack",
    NO_OTHER = "Aún no se conoce otro vendedor",
    CHEAPER = "|cffff6060+%d%% aquí|r - más barato en %s: %s (%s). Ahorro: %s",
    BEST = "|cff40ff40Mejor precio|r (%d%% más barato que %s)",
    SAME = "|cff40ff40Mismo precio|r que en otros sitios",
    PER_CLICK = "Por clic", TOP_UP = "Rellenar hasta",
    IN_BAGS = "En bolsas: %d",
    HAVE_ENOUGH = "Ya tienes %d x %s.",
    CONFIRM = "¿Comprar %d x %s por %s?",
    AGE_D = "hace %d d", AGE_H = "hace %d h", AGE_NOW = "hace <1 h",
    PROFILE_FOR = "Perfil de este personaje:",
    NEW_NAME = "Nombre del nuevo perfil:",
    CREATE = "Crear", DUPLICATE = "Duplicar", DELETE_PROFILE = "Eliminar perfil",
    EXPORT_LABEL = "Exportar / importar tu lista (copia con Ctrl+C):",
    EXPORT = "Exportar", IMPORT = "Importar",
    IMPORTED = "%d objetos importados.",
    IMPORT_FAIL = "Error al importar: datos no válidos.",
    PROFILE_CREATED = "Perfil «%s» creado.",
    PROFILE_EXISTS = "Ya existe un perfil con ese nombre.",
    BINDING = "Abrir el menú de QuickStack",
    NOTIFY_UPDATE = "Avisarme de nuevas versiones",
    UPDATE_AVAILABLE = "Hay una nueva versión disponible: %s (tienes %s).",
    UPDATE_LINK = "Descarga: %s",
    UPDATE_BANNER = "Nueva versión %s disponible",
}
tr.esMX = tr.esES
tr.ruRU = {
    ITEMS = "Предметы", PRICES = "Цены", PROFILES = "Профили", SETTINGS = "Настройки", BUGREPORT = "Сообщить об ошибке",
    HINT_ITEMS = "Alt + клик по предмету у торговца добавляет его автоматически, или перетащите предмет из сумок в поле ниже. «За клик» покупает указанное количество, «Пополнить до» доводит запас в сумках до этого количества.",
    DROP = "Перетащите предмет сюда, чтобы добавить",
    NO_ITEMS = "Предметов пока нет. Alt + левый клик у торговца или перетащите предмет сюда.",
    HINT_PRICES = "Цены сохраняются автоматически при открытии торговца (цена за штуку). Разница может быть из-за скидок за репутацию.",
    ONLY_MINE = "Только мои предметы",
    NO_PRICES = "Цен пока нет. Посетите торговца, и они появятся здесь.",
    MODIFIER = "Клавиша-модификатор",
    MODIFIER_NOTE = "Рекомендуется Alt. Ctrl открывает примерочную, Shift — окно количества.",
    AUTO_ADD = "Автоматически добавлять купленные предметы",
    SHOW_PANEL = "Показывать таблицу цен у торговцев",
    SHOW_TOOLTIP = "Показывать цены в подсказках",
    SHOW_MINIMAP = "Показывать кнопку у миникарты",
    RESET_MINIMAP = "Сбросить позицию кнопки",
    CLEAR_PRICES = "Очистить цены",
    PRICES_CLEARED = "Цены очищены.",
    UNLISTED = "Предметы без записи: при первом клике покупается полная стопка (макс. 20).",
    CONFIRM_LABEL = "Спрашивать при тратах свыше (золото, 0 = выкл.):",
    DESCRIBE = "Опишите проблему",
    CREATE_REPORT = "Создать отчёт",
    BUG_HINT = "Аддоны не могут отправлять данные из игры. Нажмите Ctrl+C, чтобы скопировать отчёт, и опубликуйте его в комментариях на странице QuickStack.",
    REPORT_PAGE = "Страница отчётов (Ctrl+C для копирования):",
    MM_LEFT = "Левый клик: открыть меню", MM_DRAG = "Перетащить: переместить кнопку",
    NOT_ENOUGH = "Недостаточно золота или товара у торговца: %s.",
    MOD_SET = "Клавиша: %s + левый клик.",
    PANEL_TITLE = "QuickStack - Цены", TT_TITLE = "Цены QuickStack",
    NO_OTHER = "Других торговцев пока нет",
    CHEAPER = "|cffff6060+%d%% здесь|r - дешевле в %s: %s (%s). Экономия: %s",
    BEST = "|cff40ff40Лучшая цена|r (на %d%% дешевле, чем в %s)",
    SAME = "|cff40ff40Та же цена|r, что и в других местах",
    PER_CLICK = "За клик", TOP_UP = "Пополнить до",
    IN_BAGS = "В сумках: %d",
    HAVE_ENOUGH = "У вас уже есть %d x %s.",
    CONFIRM = "Купить %d x %s за %s?",
    AGE_D = "%d дн. назад", AGE_H = "%d ч назад", AGE_NOW = "<1 ч назад",
    PROFILE_FOR = "Профиль этого персонажа:",
    NEW_NAME = "Название нового профиля:",
    CREATE = "Создать", DUPLICATE = "Копировать", DELETE_PROFILE = "Удалить профиль",
    EXPORT_LABEL = "Экспорт / импорт списка (копируйте через Ctrl+C):",
    EXPORT = "Экспорт", IMPORT = "Импорт",
    IMPORTED = "Импортировано предметов: %d.",
    IMPORT_FAIL = "Ошибка импорта: нет корректных данных.",
    PROFILE_CREATED = "Профиль «%s» создан.",
    PROFILE_EXISTS = "Профиль с таким названием уже существует.",
    BINDING = "Открыть меню QuickStack",
    NOTIFY_UPDATE = "Уведомлять о новых версиях",
    UPDATE_AVAILABLE = "Доступна новая версия: %s (у вас %s).",
    UPDATE_LINK = "Скачать: %s",
    UPDATE_BANNER = "Доступна новая версия %s",
}
local lang = tr[GetLocale and GetLocale() or "enUS"]
local L = setmetatable({}, { __index = function(_, k) return (lang and lang[k]) or en[k] or k end })

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local DB
local menu, RefreshItems, RefreshSettings, RefreshPrices, RefreshProfiles, RefreshPanel, UpdateBanner
local atMerchant = false

local defaults = {
    modifier = "alt",
    autoAdd = true,
    showMinimap = true,
    showPanel = true,
    showTooltip = true,
    pricesMine = true,
    confirmGold = 0,
    notifyUpdate = true,
    minimapAngle = 215,
    profiles = {},
    chars = {},
    prices = {},
}

local MODIFIERS = {
    alt   = IsAltKeyDown,
    ctrl  = IsControlKeyDown,
    shift = IsShiftKeyDown,
}

local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"
local GetMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
local CoinString = GetCoinTextureString or (C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString)
local CountFn = (C_Item and C_Item.GetItemCount) or GetItemCount

local function Print(msg)
    print("|cff33ff99" .. ADDON .. "|r: " .. msg)
end

local function Coins(copper)
    copper = math.max(1, math.floor((copper or 0) + 0.5))
    if CoinString then return CoinString(copper) end
    return copper .. "c"
end

local function CountItem(id)
    if CountFn then return CountFn(id) or 0 end
    return 0
end

local function GetIcon(id)
    if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(id) end
    if GetItemIcon then return GetItemIcon(id) end
end

local function GetName(id, link)
    local name = link and link:match("%[(.-)%]")
    if name then return name end
    local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    if getInfo then name = getInfo(id) end
    return name or ("Item " .. id)
end

local function Age(t)
    local d = math.max(0, time() - (t or 0))
    if d >= 86400 then return string.format(L.AGE_D, math.floor(d / 86400)) end
    if d >= 3600 then return string.format(L.AGE_H, math.floor(d / 3600)) end
    return L.AGE_NOW
end

-- Profiles ------------------------------------------------------------
local function CharKey()
    return (UnitName("player") or "?") .. "-" .. ((GetRealmName and GetRealmName()) or "?")
end

local function ProfileName()
    local n = DB.chars[CharKey()]
    if not n or not DB.profiles[n] then
        n = "Default"
        if not DB.profiles[n] then DB.profiles[n] = { items = {} } end
    end
    return n
end

local function Items()
    return DB.profiles[ProfileName()].items
end

local function SortedProfileNames()
    local list = {}
    for name in pairs(DB.profiles) do list[#list + 1] = name end
    table.sort(list)
    return list
end

local function RefreshAll()
    if RefreshItems and menu then RefreshItems() end
    if RefreshPrices and menu then RefreshPrices() end
    if RefreshProfiles and menu then RefreshProfiles() end
    if RefreshPanel then RefreshPanel() end
end

local function AddItem(id, link, amount, mode)
    local items = Items()
    if items[id] then return items[id], false end
    local entry = {
        name = GetName(id, link), icon = GetIcon(id),
        amount = amount or MAX_SLIDER, mode = mode or "click",
    }
    items[id] = entry
    if RefreshItems and menu and menu:IsShown() then RefreshItems() end
    if RefreshPanel and atMerchant then RefreshPanel() end
    return entry, true
end

-- Amount to buy right now for a listed item (and how many are in the bags)
local function Need(entry, id)
    if entry.mode == "target" then
        local have = CountItem(id)
        return math.max(0, (entry.amount or 0) - have), have
    end
    return entry.amount or 0, nil
end

----------------------------------------------------------------------
-- Buying
----------------------------------------------------------------------
local function GetItemData(index)
    if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
        local info = C_MerchantFrame.GetItemInfo(index)
        if not info then return end
        return info.name, info.price, info.stackCount, info.numAvailable, info.hasExtendedCost
    end
    local name, _, price, quantity, numAvailable, _, extendedCost = GetMerchantItemInfo(index)
    return name, price, quantity, numAvailable, extendedCost
end

-- buys in chunks of at most one stack per purchase
local function DoBuy(index, amount, maxStack)
    maxStack = math.max(1, maxStack or 1)
    while amount > 0 do
        local q = math.min(amount, maxStack)
        BuyMerchantItem(index, q)
        amount = amount - q
    end
end

local pending
if StaticPopupDialogs then
    StaticPopupDialogs["QUICKSTACK_CONFIRM"] = {
        text = "%s",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            if pending and atMerchant then DoBuy(pending.index, pending.amount, pending.maxStack) end
            pending = nil
        end,
        OnCancel = function() pending = nil end,
        timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
    }
end

local function BuyStack(index)
    local name, price, bundleSize, numAvailable, hasExtendedCost = GetItemData(index)
    if not name then return end

    local link = GetMerchantItemLink(index)
    local id = link and tonumber(link:match("item:(%d+)"))
    local maxStack = GetMerchantItemMaxStack(index) or 1
    bundleSize = (bundleSize and bundleSize > 0) and bundleSize or 1

    local items = Items()
    local entry = id and items[id]
    if not entry and id and DB.autoAdd then
        entry = AddItem(id, link, math.min(maxStack, MAX_SLIDER), "click")
    end

    local amount
    if entry then
        local have
        amount, have = Need(entry, id)
        if amount < 1 then
            Print(string.format(L.HAVE_ENOUGH, have or 0, name))
            return
        end
    else
        amount = math.min(maxStack, MAX_SLIDER)
    end

    -- Limit by vendor stock (-1 = unlimited)
    if numAvailable and numAvailable >= 0 then
        amount = math.min(amount, numAvailable * bundleSize)
    end
    -- Limit by gold (only computable for pure gold prices)
    if not hasExtendedCost and price and price > 0 then
        amount = math.min(amount, math.floor(GetMoney() / price) * bundleSize)
    end

    if amount < 1 then
        Print(string.format(L.NOT_ENOUGH, name))
        return
    end

    -- Ask before expensive purchases
    local cost = (not hasExtendedCost and price) and (price * amount / bundleSize) or 0
    if (DB.confirmGold or 0) > 0 and cost >= DB.confirmGold * 10000 and StaticPopup_Show then
        pending = { index = index, amount = amount, maxStack = maxStack }
        StaticPopup_Show("QUICKSTACK_CONFIRM", string.format(L.CONFIRM, amount, name, Coins(cost)))
        return
    end
    DoBuy(index, amount, maxStack)
end

local function OnItemClick(self, button)
    if button ~= "LeftButton" then return end
    local check = MODIFIERS[DB.modifier]
    if not (check and check()) then return end
    local index = self:GetID()
    if index and index > 0 then BuyStack(index) end
end

local function HookButtons()
    for i = 1, (MERCHANT_ITEMS_PER_PAGE or 10) do
        local btn = _G["MerchantItem" .. i .. "ItemButton"]
        if btn and not btn.quickStackHooked then
            btn:HookScript("OnClick", OnItemClick)
            btn.quickStackHooked = true
        end
    end
end

----------------------------------------------------------------------
-- UI toolkit (native WoW look: dialog frame, panel buttons, slider bars)
----------------------------------------------------------------------
local TPL = BackdropTemplateMixin and "BackdropTemplate" or nil

local DIALOG_BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
}
local TOOLTIP_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
local SLIDER_BACKDROP = {
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 3, right = 3, top = 6, bottom = 6 },
}

local function Box(f)
    f:SetBackdrop(TOOLTIP_BACKDROP)
    f:SetBackdropColor(0, 0, 0, 0.55)
    f:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
end

local function NewFrame(parent, name)
    return CreateFrame("Frame", name, parent, TPL)
end

local function NewText(parent, template)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    fs:SetJustifyH("LEFT")
    return fs
end

local function NewButton(parent, text, w, h)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetText(text)
    return b
end

local function SetSelected(button, selected)
    if selected then button:LockHighlight() else button:UnlockHighlight() end
end

-- Item icon with the classic action-button frame around it
local function NewIcon(parent, size)
    local tex = parent:CreateTexture(nil, "ARTWORK")
    tex:SetSize(size, size)
    tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local border = parent:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    border:SetSize(size * 1.8, size * 1.8)
    border:SetPoint("CENTER", tex, "CENTER", 0, -1)
    return tex
end

local function NewSlider(parent, w)
    local s = CreateFrame("Slider", nil, parent, TPL)
    s:SetOrientation("HORIZONTAL")
    s:SetSize(w, 17)
    s:SetBackdrop(SLIDER_BACKDROP)
    s:SetMinMaxValues(1, MAX_SLIDER)
    s:SetValueStep(1)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    s:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local thumb = s:GetThumbTexture()
    if thumb then thumb:SetSize(32, 32) end
    s:EnableMouse(true)
    return s
end

local function NewInput(parent, w, h, numeric)
    local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    e:SetSize(w, h)
    e:SetAutoFocus(false)
    if numeric then
        e:SetNumeric(true)
        e:SetMaxLetters(5)
        e:SetJustifyH("CENTER")
    end
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return e
end

local function NewCheck(parent, label, getter, setter)
    local b = CreateFrame("CheckButton", nil, parent)
    b:SetSize(26, 26)
    b:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    b:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    b:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
    b:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    local fs = NewText(b, "GameFontHighlight")
    fs:SetPoint("LEFT", b, "RIGHT", 4, 1)
    fs:SetText(label)
    function b:Refresh()
        self:SetChecked(getter() and true or false)
    end
    b:SetScript("OnClick", function(self)
        setter(self:GetChecked() and true or false)
    end)
    return b
end

local function NewScroll(parent, w, h)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetSize(w, h)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local cur, max = self:GetVerticalScroll(), self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(max, cur - delta * 40)))
    end)
    return scroll
end

local function NewMultiline(parent, w, h)
    local box = NewFrame(parent)
    box:SetSize(w, h)
    Box(box)
    local scroll = NewScroll(box, w - 14, h - 14)
    scroll:SetPoint("TOPLEFT", 7, -7)
    local eb = CreateFrame("EditBox", nil, scroll)
    eb:SetMultiLine(true)
    eb:SetFontObject(ChatFontNormal)
    eb:SetWidth(w - 14)
    eb:SetHeight(h - 14)
    eb:SetAutoFocus(false)
    eb:SetTextInsets(2, 2, 2, 2)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scroll:SetScrollChild(eb)
    scroll:EnableMouse(true)
    scroll:SetScript("OnMouseDown", function() eb:SetFocus() end)
    return box, eb
end

----------------------------------------------------------------------
-- Price tracking (recorded whenever a vendor window opens)
----------------------------------------------------------------------
local currentVendor
local currentItems = {} -- itemID -> price per single item at the open vendor

local function GetVendorInfo()
    local name = UnitName("npc") or UnitName("target") or "?"
    local guid = UnitGUID("npc")
    local npcID
    if guid and strsplit then npcID = select(6, strsplit("-", guid)) end
    local zone = (GetZoneText and GetZoneText()) or ""
    local key = (npcID and npcID ~= "") and npcID or (name .. "@" .. zone)
    return { key = key, name = name, zone = zone }
end

local function RecordPrice(id, vendor, unitPrice, itemName)
    local t = DB.prices[id]
    if not t then t = {}; DB.prices[id] = t end
    t[vendor.key] = { p = unitPrice, v = vendor.name, z = vendor.zone, t = time(), n = itemName }
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    while count > MAX_VENDORS_PER_ITEM do
        local oldestKey, oldest
        for key, e in pairs(t) do
            if key ~= vendor.key and (not oldest or e.t < oldest) then oldestKey, oldest = key, e.t end
        end
        if not oldestKey then break end
        t[oldestKey] = nil
        count = count - 1
    end
end

local function ScanMerchant()
    if not atMerchant or not DB then return end
    local vendor = GetVendorInfo()
    currentVendor = vendor
    wipe(currentItems)
    for i = 1, (GetMerchantNumItems() or 0) do
        local name, price, bundle, _, hasExtendedCost = GetItemData(i)
        local link = GetMerchantItemLink(i)
        local id = link and tonumber(link:match("item:(%d+)"))
        if id and name and price and price > 0 and not hasExtendedCost then
            local unit = price / ((bundle and bundle > 0) and bundle or 1)
            currentItems[id] = unit
            RecordPrice(id, vendor, unit, name)
        end
    end
end

local function BestElsewhere(id, hereKey)
    local best
    for key, e in pairs(DB.prices[id] or {}) do
        if key ~= hereKey and (not best or e.p < best.p) then best = e end
    end
    return best
end

local function Where(e)
    return (e.z and e.z ~= "") and e.z or e.v or "?"
end

local function CompareText(id, unit, hereKey, need)
    local best = BestElsewhere(id, hereKey)
    if not best then return L.NO_OTHER end
    local diff = (unit - best.p) / best.p * 100
    if diff >= 1 then
        local saved = (unit - best.p) * math.max(1, need or 1)
        return string.format(L.CHEAPER, math.floor(diff + 0.5), Where(best),
            Coins(best.p), Age(best.t), Coins(saved))
    elseif diff <= -1 then
        return string.format(L.BEST, math.floor(-diff + 0.5), Where(best))
    end
    return L.SAME
end

-- Price table next to the vendor window ------------------------------
local panel
local panelRows = {}
local PANEL_W = 350
local PANEL_ROW_H = 48
local MAX_PANEL_ROWS = 10

local function BuildPanel()
    panel = NewFrame(MerchantFrame, "QuickStackPricePanel")
    panel:SetWidth(PANEL_W)
    panel:SetPoint("TOPLEFT", MerchantFrame, "TOPRIGHT", 0, -22)
    panel:SetBackdrop(DIALOG_BACKDROP)
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 22, -20)
    title:SetText(L.PANEL_TITLE)
    panel.title = title
end

local function GetPanelRow(i)
    local row = panelRows[i]
    if row then return row end
    row = CreateFrame("Frame", nil, panel)
    row:SetSize(PANEL_W - 40, PANEL_ROW_H - 4)
    row:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -(44 + (i - 1) * PANEL_ROW_H))
    row.icon = NewIcon(row, 24)
    row.icon:SetPoint("TOPLEFT", 6, -4)
    row.name = NewText(row, "GameFontNormal")
    row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 10, 1)
    row.name:SetWidth(170)
    row.name:SetWordWrap(false)
    row.price = NewText(row, "GameFontHighlight")
    row.price:SetPoint("TOPRIGHT", 0, -2)
    row.price:SetJustifyH("RIGHT")
    row.info = NewText(row, "GameFontHighlightSmall")
    row.info:SetPoint("TOPLEFT", row, "TOPLEFT", 44, -18)
    row.info:SetWidth(PANEL_W - 40 - 48)
    row.info:SetHeight(26)
    row.info:SetJustifyV("TOP")
    row.info:SetWordWrap(true)
    panelRows[i] = row
    return row
end

RefreshPanel = function()
    if not DB then return end
    if not (atMerchant and DB.showPanel and MerchantFrame) then
        if panel then panel:Hide() end
        return
    end
    local list = {}
    for id, e in pairs(Items()) do
        local unit = currentItems[id]
        if unit then
            local need = Need(e, id)
            list[#list + 1] = { id = id, e = e, unit = unit, need = need }
        end
    end
    table.sort(list, function(a, b) return (a.e.name or "") < (b.e.name or "") end)
    if #list == 0 then
        if panel then panel:Hide() end
        return
    end
    if not panel then BuildPanel() end
    local shown = math.min(#list, MAX_PANEL_ROWS)
    for i = 1, shown do
        local it = list[i]
        local row = GetPanelRow(i)
        row.icon:SetTexture(it.e.icon or QUESTION)
        row.name:SetText(it.e.name or ("Item " .. it.id))
        if it.need > 0 then
            row.price:SetText(string.format("x%d  %s", it.need, Coins(it.unit * it.need)))
        else
            row.price:SetText("|cff40ff40" .. L.OK .. "|r")
        end
        row.info:SetText(CompareText(it.id, it.unit, currentVendor and currentVendor.key, it.need))
        row:Show()
    end
    for i = shown + 1, #panelRows do panelRows[i]:Hide() end
    panel:SetHeight(44 + shown * PANEL_ROW_H + 16)
    panel:Show()
end

-- Price lines in item tooltips ---------------------------------------
local function AddPriceLines(tooltip, id)
    if not (DB and DB.showTooltip and id) then return end
    local t = DB.prices[id]
    if not t then return end
    local list = {}
    for _, e in pairs(t) do list[#list + 1] = e end
    if #list == 0 then return end
    table.sort(list, function(a, b) return a.p < b.p end)
    tooltip:AddLine(" ")
    tooltip:AddLine(L.TT_TITLE, 1, 0.82, 0)
    for i = 1, math.min(4, #list) do
        local e = list[i]
        local left = e.v or "?"
        if e.z and e.z ~= "" then left = left .. " (" .. e.z .. ")" end
        left = left .. "  |cff888888" .. Age(e.t) .. "|r"
        local r, g, b = 0.8, 0.8, 0.8
        if i == 1 then r, g, b = 0.25, 1, 0.25 end
        tooltip:AddDoubleLine(left, Coins(e.p), r, g, b, 1, 1, 1)
    end
    tooltip:Show()
end

local function HookTooltips()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data)
            if tt ~= GameTooltip or not data then return end
            pcall(AddPriceLines, tt, data.id)
        end)
    elseif GameTooltip and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetItem", function(tt)
            local _, link = tt:GetItem()
            local id = link and tonumber(link:match("item:(%d+)"))
            pcall(AddPriceLines, tt, id)
        end)
    end
end

----------------------------------------------------------------------
-- Minimap button (draggable along the minimap edge; round and square minimaps)
----------------------------------------------------------------------
local mmButton
local atan2 = math.atan2 or math.atan
local SHAPES = {
    ["ROUND"] = { true, true, true, true },
    ["SQUARE"] = { false, false, false, false },
    ["CORNER-TOPLEFT"] = { false, false, false, true },
    ["CORNER-TOPRIGHT"] = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
    ["CORNER-BOTTOMRIGHT"] = { true, false, false, false },
    ["SIDE-LEFT"] = { false, true, false, true },
    ["SIDE-RIGHT"] = { true, false, true, false },
    ["SIDE-TOP"] = { false, false, true, true },
    ["SIDE-BOTTOM"] = { true, true, false, false },
    ["TRICORNER-TOPLEFT"] = { false, true, true, true },
    ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
    ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { true, true, true, false },
}

local function UpdateMinimapPosition()
    if not mmButton then return end
    local angle = math.rad(DB.minimapAngle or 215)
    local x, y = math.cos(angle), math.sin(angle)
    local q = 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    local shape = (GetMinimapShape and GetMinimapShape()) or "ROUND"
    local quad = SHAPES[shape] or SHAPES.ROUND
    local w = (Minimap:GetWidth() / 2) + 5
    local h = (Minimap:GetHeight() / 2) + 5
    if quad[q] then
        x, y = x * w, y * h
    else
        local dw = math.sqrt(2 * w * w) - 10
        local dh = math.sqrt(2 * h * h) - 10
        x = math.max(-w, math.min(x * dw, w))
        y = math.max(-h, math.min(y * dh, h))
    end
    mmButton:ClearAllPoints()
    mmButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function UpdateMinimapVisibility()
    if not mmButton then return end
    if DB.showMinimap then mmButton:Show() else mmButton:Hide() end
end

local ToggleMenu -- defined below

local function CreateMinimapButton()
    local b = CreateFrame("Button", "QuickStackMinimapButton", Minimap)
    b:SetSize(32, 32)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("TOPLEFT", 7, -5)
    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(19, 19)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:SetPoint("TOPLEFT", 6, -5)
    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT")

    local function OnUpdate()
        local mx, my = Minimap:GetCenter()
        local scale = Minimap:GetEffectiveScale()
        local cx, cy = GetCursorPosition()
        cx, cy = cx / scale, cy / scale
        DB.minimapAngle = math.deg(atan2(cy - my, cx - mx))
        UpdateMinimapPosition()
    end
    b:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", OnUpdate)
    end)
    b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    b:SetScript("OnClick", function() ToggleMenu() end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("QuickStack", 1, 0.82, 0)
        GameTooltip:AddLine(L.MM_LEFT, 1, 1, 1)
        GameTooltip:AddLine(L.MM_DRAG, 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)

    mmButton = b
    UpdateMinimapPosition()
    UpdateMinimapVisibility()
end

----------------------------------------------------------------------
-- Menu
----------------------------------------------------------------------
local pages, tabs = {}, {}
local PAGE_W = 512

local function ShowTab(key)
    for k, page in pairs(pages) do
        if k == key then page:Show() else page:Hide() end
    end
    for k, tab in pairs(tabs) do SetSelected(tab, k == key) end
    menu.currentTab = key
    if key == "items" and RefreshItems then RefreshItems() end
    if key == "prices" and RefreshPrices then RefreshPrices() end
    if key == "profiles" and RefreshProfiles then RefreshProfiles() end
    if key == "settings" and RefreshSettings then RefreshSettings() end
end

local function NewDeleteButton(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(24, 24)
    b:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    b:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
    b:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight", "ADD")
    return b
end

local function BuildItemsPage(page)
    local ROW_H = 64
    local ROW_GAP = 4
    local rows = {}

    local hint = NewText(page, "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 0, 0)
    hint:SetWidth(PAGE_W)
    hint:SetWordWrap(true)
    hint:SetText(L.HINT_ITEMS)

    local drop = CreateFrame("Button", nil, page, TPL)
    drop:SetSize(PAGE_W, 34)
    drop:SetPoint("TOPLEFT", 0, -50)
    Box(drop)
    local plus = drop:CreateTexture(nil, "ARTWORK")
    plus:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
    plus:SetSize(20, 20)
    local dropText = NewText(drop, "GameFontNormal")
    dropText:SetPoint("CENTER", 12, 0)
    dropText:SetText(L.DROP)
    plus:SetPoint("RIGHT", dropText, "LEFT", -6, 0)
    drop:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    local function AddFromCursor()
        local kind, id, link = GetCursorInfo()
        if kind == "item" and id then
            AddItem(id, link)
            ClearCursor()
            RefreshItems()
        end
    end
    drop:SetScript("OnReceiveDrag", AddFromCursor)
    drop:SetScript("OnClick", AddFromCursor)

    local scroll = NewScroll(page, PAGE_W, 326)
    scroll:SetPoint("TOPLEFT", 0, -92)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(PAGE_W, 1)
    scroll:SetScrollChild(content)

    local empty = NewText(page, "GameFontHighlight")
    empty:SetPoint("TOPLEFT", 6, -104)
    empty:SetWidth(PAGE_W - 12)
    empty:SetWordWrap(true)
    empty:SetText(L.NO_ITEMS)

    local function SetRowAmount(row, amount)
        row.updating = true
        row.slider:SetValue(math.min(MAX_SLIDER, amount))
        row.edit:SetText(tostring(amount))
        row.updating = false
    end

    local function SetModeText(row, entry)
        row.mode:SetText(entry.mode == "target" and L.TOP_UP or L.PER_CLICK)
    end

    local function CreateRow()
        local row = NewFrame(content)
        row:SetSize(PAGE_W - 4, ROW_H)
        Box(row)

        row.icon = NewIcon(row, 32)
        row.icon:SetPoint("TOPLEFT", 12, -10)

        row.name = NewText(row, "GameFontHighlight")
        row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 10, 1)
        row.name:SetWidth(230)
        row.name:SetWordWrap(false)

        row.owned = NewText(row, "GameFontHighlightSmall")
        row.owned:SetPoint("TOPLEFT", row.icon, "BOTTOMRIGHT", 10, 12)
        row.owned:SetWidth(230)

        row.del = NewDeleteButton(row)
        row.del:SetPoint("TOPRIGHT", -8, -8)
        row.del:SetScript("OnClick", function()
            if row.itemID then
                Items()[row.itemID] = nil
                RefreshItems()
                if RefreshPanel then RefreshPanel() end
            end
        end)

        row.edit = NewInput(row, 48, 20, true)
        row.edit:SetPoint("TOPRIGHT", -44, -10)
        local function Commit(self)
            local e = row.itemID and Items()[row.itemID]
            if not e then return end
            local v = tonumber(self:GetText()) or e.amount or 1
            v = math.max(1, math.min(MAX_AMOUNT, math.floor(v)))
            e.amount = v
            SetRowAmount(row, v)
            if RefreshPanel then RefreshPanel() end
        end
        row.edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        row.edit:SetScript("OnEditFocusLost", Commit)

        row.mode = NewButton(row, L.PER_CLICK, 104, 22)
        row.mode:SetPoint("TOPRIGHT", -100, -9)
        row.mode:SetScript("OnClick", function()
            local e = row.itemID and Items()[row.itemID]
            if not e then return end
            e.mode = (e.mode == "target") and "click" or "target"
            SetModeText(row, e)
            if RefreshPanel then RefreshPanel() end
        end)

        row.slider = NewSlider(row, PAGE_W - 4 - 54 - 20)
        row.slider:SetPoint("BOTTOMLEFT", 54, 8)
        row.slider:SetScript("OnValueChanged", function(self, v)
            if row.updating or not row.itemID then return end
            local e = Items()[row.itemID]
            if not e then return end
            v = math.floor(v + 0.5)
            e.amount = v
            row.edit:SetText(tostring(v))
            if RefreshPanel then RefreshPanel() end
        end)
        return row
    end

    RefreshItems = function()
        local items = Items()
        local list = {}
        for id, e in pairs(items) do
            if type(e.name) ~= "string" or e.name:match("^Item %d+$") then e.name = GetName(id) end
            if not e.icon then e.icon = GetIcon(id) end
            list[#list + 1] = { id = id, e = e }
        end
        table.sort(list, function(a, b) return (a.e.name or "") < (b.e.name or "") end)

        for i, it in ipairs(list) do
            local row = rows[i]
            if not row then row = CreateRow(); rows[i] = row end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(i - 1) * (ROW_H + ROW_GAP))
            row.itemID = nil -- avoid writing slider updates to the previous item
            local amount = math.max(1, math.min(MAX_AMOUNT, it.e.amount or MAX_SLIDER))
            it.e.amount = amount
            row.icon:SetTexture(it.e.icon or QUESTION)
            row.name:SetText(it.e.name)
            row.owned:SetText(string.format(L.IN_BAGS, CountItem(it.id)))
            SetRowAmount(row, amount)
            SetModeText(row, it.e)
            row.itemID = it.id
            row:Show()
        end
        for i = #list + 1, #rows do rows[i]:Hide() end
        content:SetHeight(math.max(1, #list * (ROW_H + ROW_GAP)))
        if #list == 0 then empty:Show() else empty:Hide() end
    end
end

local function BuildPricesPage(page)
    local MAX_LINES = 4
    local LINE_H = 14
    local rows = {}

    local hint = NewText(page, "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 0, 0)
    hint:SetWidth(PAGE_W)
    hint:SetWordWrap(true)
    hint:SetText(L.HINT_PRICES)

    local only = NewCheck(page, L.ONLY_MINE,
        function() return DB.pricesMine end,
        function(v) DB.pricesMine = v; RefreshPrices() end)
    only:SetPoint("TOPLEFT", 0, -44)
    page.onlyCheck = only

    local scroll = NewScroll(page, PAGE_W, 336)
    scroll:SetPoint("TOPLEFT", 0, -78)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(PAGE_W, 1)
    scroll:SetScrollChild(content)

    local empty = NewText(page, "GameFontHighlight")
    empty:SetPoint("TOPLEFT", 6, -92)
    empty:SetWidth(PAGE_W - 12)
    empty:SetWordWrap(true)
    empty:SetText(L.NO_PRICES)

    local function CreateRow()
        local row = NewFrame(content)
        row:SetWidth(PAGE_W - 4)
        Box(row)
        row.icon = NewIcon(row, 28)
        row.icon:SetPoint("TOPLEFT", 12, -8)
        row.name = NewText(row, "GameFontNormal")
        row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 10, -1)
        row.name:SetWidth(300)
        row.name:SetWordWrap(false)
        row.best = NewText(row, "GameFontHighlight")
        row.best:SetPoint("TOPRIGHT", -12, -12)
        row.best:SetJustifyH("RIGHT")
        row.left, row.right = {}, {}
        for i = 1, MAX_LINES do
            local l = NewText(row, "GameFontHighlightSmall")
            l:SetPoint("TOPLEFT", 52, -(34 + (i - 1) * LINE_H))
            l:SetWidth(340)
            l:SetWordWrap(false)
            local r = NewText(row, "GameFontHighlightSmall")
            r:SetPoint("TOPRIGHT", -12, -(34 + (i - 1) * LINE_H))
            r:SetJustifyH("RIGHT")
            row.left[i], row.right[i] = l, r
        end
        return row
    end

    RefreshPrices = function()
        local items = Items()
        local list = {}
        for id, t in pairs(DB.prices) do
            if not DB.pricesMine or items[id] then
                local vendors = {}
                for _, e in pairs(t) do vendors[#vendors + 1] = e end
                if #vendors > 0 then
                    table.sort(vendors, function(a, b) return a.p < b.p end)
                    local name = (items[id] and items[id].name) or vendors[1].n or ("Item " .. id)
                    list[#list + 1] = { id = id, name = name, vendors = vendors }
                end
            end
        end
        table.sort(list, function(a, b) return a.name < b.name end)

        local y = 0
        for i, it in ipairs(list) do
            local row = rows[i]
            if not row then row = CreateRow(); rows[i] = row end
            local n = math.min(MAX_LINES, #it.vendors)
            local h = 38 + n * LINE_H + 6
            row:SetHeight(h)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            row.icon:SetTexture((items[it.id] and items[it.id].icon) or GetIcon(it.id) or QUESTION)
            row.name:SetText(it.name)
            local best = it.vendors[1]
            row.best:SetText(Coins(best.p))
            for li = 1, MAX_LINES do
                local e = it.vendors[li]
                if li <= n and e then
                    local left = e.v or "?"
                    if e.z and e.z ~= "" then left = left .. " (" .. e.z .. ")" end
                    left = left .. "  |cff888888" .. Age(e.t) .. "|r"
                    local right = Coins(e.p)
                    if li == 1 then
                        left = "|cff40ff40" .. left .. "|r"
                    else
                        local pct = math.floor((e.p - best.p) / best.p * 100 + 0.5)
                        if pct >= 1 then right = right .. " |cffff6060+" .. pct .. "%|r" end
                    end
                    row.left[li]:SetText(left)
                    row.right[li]:SetText(right)
                    row.left[li]:Show()
                    row.right[li]:Show()
                else
                    row.left[li]:Hide()
                    row.right[li]:Hide()
                end
            end
            row:Show()
            y = y + h + 4
        end
        for i = #list + 1, #rows do rows[i]:Hide() end
        content:SetHeight(math.max(1, y))
        if #list == 0 then empty:Show() else empty:Hide() end
        page.onlyCheck:Refresh()
    end
end

-- Export / import --------------------------------------------------------
local function ExportItems()
    local ids = {}
    for id in pairs(Items()) do ids[#ids + 1] = id end
    table.sort(ids)
    local parts = { "QS1" }
    for _, id in ipairs(ids) do
        local e = Items()[id]
        parts[#parts + 1] = id .. ":" .. (e.amount or 1) .. ":" .. ((e.mode == "target") and "t" or "c")
    end
    return table.concat(parts, ";")
end

local function ImportItems(text)
    text = (text or ""):gsub("%s+", "")
    if text:sub(1, 4) ~= "QS1;" then return nil end
    local n = 0
    for id, amount, mode in text:sub(5):gmatch("(%d+):(%d+):([ct])") do
        id = tonumber(id)
        amount = math.max(1, math.min(MAX_AMOUNT, tonumber(amount)))
        local e = Items()[id]
        if not e then
            e = { name = GetName(id), icon = GetIcon(id) }
            Items()[id] = e
        end
        e.amount = amount
        e.mode = (mode == "t") and "target" or "click"
        n = n + 1
    end
    if n == 0 then return nil end
    return n
end

local function BuildProfilesPage(page)
    local label = NewText(page, "GameFontNormal")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(L.PROFILE_FOR)

    local prev = NewButton(page, "<", 30, 24)
    prev:SetPoint("TOPLEFT", 0, -22)
    local nameText = NewText(page, "GameFontHighlightLarge")
    nameText:SetPoint("TOPLEFT", 40, -26)
    nameText:SetWidth(220)
    local nextB = NewButton(page, ">", 30, 24)
    nextB:SetPoint("TOPLEFT", 270, -22)

    local function Cycle(step)
        local names = SortedProfileNames()
        local cur = ProfileName()
        local idx = 1
        for i, n in ipairs(names) do if n == cur then idx = i end end
        idx = ((idx - 1 + step) % #names) + 1
        DB.chars[CharKey()] = names[idx]
        RefreshAll()
    end
    prev:SetScript("OnClick", function() Cycle(-1) end)
    nextB:SetScript("OnClick", function() Cycle(1) end)

    local newLabel = NewText(page, "GameFontHighlightSmall")
    newLabel:SetPoint("TOPLEFT", 0, -62)
    newLabel:SetText(L.NEW_NAME)
    local nameInput = NewInput(page, 220, 24, false)
    nameInput:SetPoint("TOPLEFT", 6, -78)
    nameInput:SetMaxLetters(24)

    local function CreateProfile(copy)
        local name = (nameInput:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then return end
        if DB.profiles[name] then Print(L.PROFILE_EXISTS) return end
        local items = {}
        if copy then
            for id, e in pairs(Items()) do
                items[id] = { name = e.name, icon = e.icon, amount = e.amount, mode = e.mode }
            end
        end
        DB.profiles[name] = { items = items }
        DB.chars[CharKey()] = name
        nameInput:SetText("")
        nameInput:ClearFocus()
        Print(string.format(L.PROFILE_CREATED, name))
        RefreshAll()
    end
    local create = NewButton(page, L.CREATE, 100, 24)
    create:SetPoint("TOPLEFT", 240, -78)
    create:SetScript("OnClick", function() CreateProfile(false) end)
    local dup = NewButton(page, L.DUPLICATE, 110, 24)
    dup:SetPoint("TOPLEFT", 346, -78)
    dup:SetScript("OnClick", function() CreateProfile(true) end)

    local del = NewButton(page, L.DELETE_PROFILE, 220, 24)
    del:SetPoint("TOPLEFT", 0, -114)
    del:SetScript("OnClick", function()
        local cur = ProfileName()
        if cur == "Default" then return end
        DB.profiles[cur] = nil
        for key, n in pairs(DB.chars) do
            if n == cur then DB.chars[key] = nil end
        end
        RefreshAll()
    end)
    page.deleteButton = del

    local exLabel = NewText(page, "GameFontHighlightSmall")
    exLabel:SetPoint("TOPLEFT", 0, -158)
    exLabel:SetText(L.EXPORT_LABEL)
    local box, edit = NewMultiline(page, PAGE_W, 130)
    box:SetPoint("TOPLEFT", 0, -176)

    local export = NewButton(page, L.EXPORT, 120, 24)
    export:SetPoint("TOPLEFT", 0, -314)
    export:SetScript("OnClick", function()
        edit:SetText(ExportItems())
        edit:SetFocus()
        edit:HighlightText()
    end)
    local import = NewButton(page, L.IMPORT, 120, 24)
    import:SetPoint("TOPLEFT", 130, -314)
    import:SetScript("OnClick", function()
        local n = ImportItems(edit:GetText())
        if n then
            Print(string.format(L.IMPORTED, n))
            RefreshAll()
        else
            Print(L.IMPORT_FAIL)
        end
    end)

    RefreshProfiles = function()
        nameText:SetText(ProfileName())
        if ProfileName() == "Default" then del:Disable() else del:Enable() end
    end
end

local function BuildSettingsPage(page)
    local label = NewText(page, "GameFontNormal")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(L.MODIFIER)

    local modButtons = {}
    local x = 0
    for _, key in ipairs({ "alt", "ctrl", "shift" }) do
        local b = NewButton(page, key:sub(1, 1):upper() .. key:sub(2), 90, 24)
        b:SetPoint("TOPLEFT", x, -22)
        b:SetScript("OnClick", function()
            DB.modifier = key
            RefreshSettings()
        end)
        modButtons[key] = b
        x = x + 96
    end

    local note = NewText(page, "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", 0, -56)
    note:SetWidth(PAGE_W)
    note:SetWordWrap(true)
    note:SetText(L.MODIFIER_NOTE)

    local c1 = NewCheck(page, L.AUTO_ADD,
        function() return DB.autoAdd end, function(v) DB.autoAdd = v end)
    c1:SetPoint("TOPLEFT", 0, -92)
    local c2 = NewCheck(page, L.SHOW_PANEL,
        function() return DB.showPanel end,
        function(v) DB.showPanel = v; RefreshPanel() end)
    c2:SetPoint("TOPLEFT", 0, -122)
    local c3 = NewCheck(page, L.SHOW_TOOLTIP,
        function() return DB.showTooltip end, function(v) DB.showTooltip = v end)
    c3:SetPoint("TOPLEFT", 0, -152)
    local c4 = NewCheck(page, L.SHOW_MINIMAP,
        function() return DB.showMinimap end,
        function(v) DB.showMinimap = v; UpdateMinimapVisibility() end)
    c4:SetPoint("TOPLEFT", 0, -182)
    local c5 = NewCheck(page, L.NOTIFY_UPDATE,
        function() return DB.notifyUpdate end, function(v) DB.notifyUpdate = v end)
    c5:SetPoint("TOPLEFT", 0, -212)

    local confirmLabel = NewText(page, "GameFontHighlight")
    confirmLabel:SetPoint("TOPLEFT", 0, -250)
    confirmLabel:SetWidth(380)
    confirmLabel:SetText(L.CONFIRM_LABEL)
    local confirmInput = NewInput(page, 60, 22, true)
    confirmInput:SetPoint("TOPLEFT", 396, -246)
    confirmInput:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    confirmInput:SetScript("OnEditFocusLost", function(self)
        DB.confirmGold = math.max(0, math.floor(tonumber(self:GetText()) or 0))
        self:SetText(tostring(DB.confirmGold))
    end)

    local reset = NewButton(page, L.RESET_MINIMAP, 240, 24)
    reset:SetPoint("TOPLEFT", 0, -288)
    reset:SetScript("OnClick", function()
        DB.minimapAngle = defaults.minimapAngle
        UpdateMinimapPosition()
    end)
    local clear = NewButton(page, L.CLEAR_PRICES, 240, 24)
    clear:SetPoint("TOPLEFT", 250, -288)
    clear:SetScript("OnClick", function()
        wipe(DB.prices)
        if atMerchant then ScanMerchant() end
        RefreshAll()
        Print(L.PRICES_CLEARED)
    end)

    local info = NewText(page, "GameFontHighlightSmall")
    info:SetPoint("TOPLEFT", 0, -328)
    info:SetWidth(PAGE_W)
    info:SetWordWrap(true)
    info:SetText(L.UNLISTED)

    RefreshSettings = function()
        for key, b in pairs(modButtons) do SetSelected(b, DB.modifier == key) end
        c1:Refresh(); c2:Refresh(); c3:Refresh(); c4:Refresh(); c5:Refresh()
        confirmInput:SetText(tostring(DB.confirmGold or 0))
    end
end

local function BuildBugPage(page)
    local label = NewText(page, "GameFontNormal")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(L.DESCRIBE)

    local inputBox, input = NewMultiline(page, PAGE_W, 130)
    inputBox:SetPoint("TOPLEFT", 0, -22)

    local create = NewButton(page, L.CREATE_REPORT, 150, 24)
    create:SetPoint("TOPLEFT", 0, -160)

    local hint = NewText(page, "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 0, -194)
    hint:SetWidth(PAGE_W)
    hint:SetWordWrap(true)
    hint:SetText(L.BUG_HINT)

    local outBox, output = NewMultiline(page, PAGE_W, 110)
    outBox:SetPoint("TOPLEFT", 0, -244)

    if BUG_URL ~= "" then
        local urlLabel = NewText(page, "GameFontNormalSmall")
        urlLabel:SetPoint("TOPLEFT", 0, -364)
        urlLabel:SetText(L.REPORT_PAGE)
        local url = CreateFrame("EditBox", nil, page, TPL)
        url:SetSize(PAGE_W, 26)
        url:SetPoint("TOPLEFT", 0, -382)
        Box(url)
        url:SetFontObject(ChatFontNormal)
        url:SetAutoFocus(false)
        url:SetTextInsets(8, 8, 0, 0)
        url:SetText(BUG_URL)
        url:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        url:SetScript("OnTextChanged", function(self, user) if user then self:SetText(BUG_URL) end end)
    end

    create:SetScript("OnClick", function()
        local wowVersion, build, _, toc = GetBuildInfo()
        local count = 0
        for _ in pairs(Items()) do count = count + 1 end
        local text = string.format(
            "QuickStack %s\nWoW %s (build %s, interface %s), locale %s\nModifier: %s, auto-add: %s, profile: %s, listed items: %d\n\nProblem:\n%s",
            (GetMeta and GetMeta(ADDON, "Version")) or "?",
            tostring(wowVersion), tostring(build), tostring(toc), tostring(GetLocale()),
            tostring(DB.modifier), tostring(DB.autoAdd), ProfileName(), count, input:GetText() or "")
        output:SetText(text)
        output:SetFocus()
        output:HighlightText()
    end)
end

local function BuildMenu()
    if menu then return end
    menu = NewFrame(UIParent, "QuickStackMenu")
    menu:SetSize(560, 540)
    menu:SetPoint("CENTER")
    menu:SetFrameStrata("DIALOG")
    menu:SetMovable(true)
    menu:EnableMouse(true)
    menu:SetClampedToScreen(true)
    menu:RegisterForDrag("LeftButton")
    menu:SetScript("OnDragStart", menu.StartMoving)
    menu:SetScript("OnDragStop", menu.StopMovingOrSizing)
    menu:SetBackdrop(DIALOG_BACKDROP)
    tinsert(UISpecialFrames, "QuickStackMenu")
    menu:Hide()

    local header = menu:CreateTexture(nil, "ARTWORK")
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    header:SetSize(300, 64)
    header:SetPoint("TOP", 0, 12)
    local title = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", header, "TOP", 0, -14)
    title:SetText("QuickStack")

    local ver = menu:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    ver:SetPoint("BOTTOMLEFT", 26, 14)
    ver:SetText("v" .. ((GetMeta and GetMeta(ADDON, "Version")) or ""))

    menu.update = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    menu.update:SetPoint("BOTTOMRIGHT", -26, 14)
    menu.update:SetJustifyH("RIGHT")

    -- close button: hides the menu explicitly and sits above everything else
    local close = CreateFrame("Button", nil, menu, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetFrameLevel(menu:GetFrameLevel() + 20)
    close:SetScript("OnClick", function() menu:Hide() end)

    local tabDefs = {
        { key = "items", label = L.ITEMS },
        { key = "prices", label = L.PRICES },
        { key = "profiles", label = L.PROFILES },
        { key = "settings", label = L.SETTINGS },
        { key = "bug", label = L.BUGREPORT },
    }
    for i, def in ipairs(tabDefs) do
        local t = NewButton(menu, def.label, 98, 24)
        t:SetPoint("TOPLEFT", 24 + (i - 1) * 102, -56)
        t:SetScript("OnClick", function() ShowTab(def.key) end)
        tabs[def.key] = t

        local page = CreateFrame("Frame", nil, menu)
        page:SetPoint("TOPLEFT", 24, -92)
        page:SetPoint("BOTTOMRIGHT", -24, 28)
        page:Hide()
        pages[def.key] = page
    end

    BuildItemsPage(pages.items)
    BuildPricesPage(pages.prices)
    BuildProfilesPage(pages.profiles)
    BuildSettingsPage(pages.settings)
    BuildBugPage(pages.bug)
    if UpdateBanner then UpdateBanner() end
end

ToggleMenu = function()
    BuildMenu()
    if menu:IsShown() then
        menu:Hide()
    else
        menu:Show()
        ShowTab(menu.currentTab or "items")
    end
end

-- key binding support (Bindings.xml)
BINDING_HEADER_QUICKSTACK = "QuickStack"
BINDING_NAME_QUICKSTACK_TOGGLE = L.BINDING
function QuickStack_Toggle()
    if DB then ToggleMenu() end
end

----------------------------------------------------------------------
-- Update notification (version exchange between players of the addon)
----------------------------------------------------------------------
local function OwnVersion()
    return GetMeta and GetMeta(ADDON, "Version") or nil
end

local function ParseVersion(v)
    local a, b, c = tostring(v or ""):match("^v?(%d+)%.?(%d*)%.?(%d*)")
    if not a then return nil end
    return { tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0 }
end

local function CompareVersions(x, y)
    for i = 1, 3 do
        if x[i] ~= y[i] then return x[i] > y[i] and 1 or -1 end
    end
    return 0
end

UpdateBanner = function()
    if not (menu and menu.update) then return end
    local newest = DB and DB.newestSeen
    if newest then
        menu.update:SetText("|cffff9933" .. string.format(L.UPDATE_BANNER, newest) .. "|r")
    else
        menu.update:SetText("")
    end
end

local function NotifyUpdate()
    if not (DB and DB.newestSeen) then return end
    UpdateBanner()
    if DB.notifyUpdate and DB.notifiedVersion ~= DB.newestSeen then
        DB.notifiedVersion = DB.newestSeen
        Print("|cffff9933" .. string.format(L.UPDATE_AVAILABLE, DB.newestSeen, OwnVersion() or "?") .. "|r")
        Print(string.format(L.UPDATE_LINK, DOWNLOAD_URL))
    end
end

local function SendVersion(channel, target)
    local v = OwnVersion()
    if not (v and ParseVersion(v)) then return end
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    if send then pcall(send, PREFIX, "V:" .. v, channel, target) end
end

local lastBroadcast = 0
local function BroadcastVersion()
    if time() - lastBroadcast < 30 then return end
    lastBroadcast = time()
    if IsInGuild and IsInGuild() then SendVersion("GUILD") end
    if IsInRaid and IsInRaid() then
        SendVersion("RAID")
    elseif IsInGroup and IsInGroup() then
        SendVersion("PARTY")
    end
    if IsInGroup and LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendVersion("INSTANCE_CHAT")
    end
end

local replied = {}
local function OnRemoteVersion(text, channel, sender)
    local v = tostring(text or ""):match("^V:(.+)$")
    local remote, own = ParseVersion(v), ParseVersion(OwnVersion())
    if not (remote and own and DB) then return end
    local c = CompareVersions(remote, own)
    if c > 0 then
        local known = ParseVersion(DB.newestSeen)
        if not known or CompareVersions(remote, known) > 0 then DB.newestSeen = v end
        NotifyUpdate()
    elseif c < 0 and channel ~= "WHISPER" and sender and not replied[sender] then
        -- tell players with an older version about ours so the news spreads
        replied[sender] = true
        SendVersion("WHISPER", sender)
    end
end

----------------------------------------------------------------------
-- Events & slash command
----------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_UPDATE")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        QuickStackDB = QuickStackDB or {}
        DB = QuickStackDB
        -- migrate the item list of versions before 1.3 into the "Default" profile
        if DB.items and not DB.profiles then
            DB.profiles = { Default = { items = DB.items } }
        end
        DB.items = nil
        for k, v in pairs(defaults) do
            if DB[k] == nil then
                if type(v) == "table" then DB[k] = {} else DB[k] = v end
            end
        end
        if not DB.profiles.Default then DB.profiles.Default = { items = {} } end
        if not MODIFIERS[DB.modifier] then DB.modifier = "alt" end
        CreateMinimapButton()
        HookTooltips()
        if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
            C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
        elseif RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(PREFIX)
        end
        -- forget an old update hint once the addon has been updated
        local own, seen = ParseVersion(OwnVersion()), ParseVersion(DB.newestSeen)
        if own and seen and CompareVersions(seen, own) <= 0 then
            DB.newestSeen, DB.notifiedVersion = nil, nil
        end
    elseif event == "MERCHANT_SHOW" then
        atMerchant = true
        HookButtons()
        ScanMerchant()
        RefreshPanel()
        if menu and menu:IsShown() and menu.currentTab == "prices" then RefreshPrices() end
    elseif event == "MERCHANT_UPDATE" then
        if atMerchant then
            ScanMerchant()
            RefreshPanel()
        end
    elseif event == "MERCHANT_CLOSED" then
        atMerchant = false
        currentVendor = nil
        wipe(currentItems)
        if panel then panel:Hide() end
        if menu and menu:IsShown() and menu.currentTab == "prices" then RefreshPrices() end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if DB then
            NotifyUpdate()
            if C_Timer and C_Timer.After then C_Timer.After(8, BroadcastVersion) else BroadcastVersion() end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        if DB then BroadcastVersion() end
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == PREFIX and DB then OnRemoteVersion(arg2, arg3, arg4) end
    elseif event == "BAG_UPDATE_DELAYED" then
        if not DB then return end
        if menu and menu:IsShown() and menu.currentTab == "items" and RefreshItems then RefreshItems() end
        if atMerchant then RefreshPanel() end
    end
end)

-- /qs opens the menu; /qs alt | ctrl | shift sets the modifier directly
SLASH_QUICKSTACK1 = "/qs"
SLASH_QUICKSTACK2 = "/quickstack"
SlashCmdList["QUICKSTACK"] = function(msg)
    msg = (msg or ""):lower():gsub("%s+", "")
    if MODIFIERS[msg] then
        DB.modifier = msg
        if RefreshSettings then RefreshSettings() end
        Print(string.format(L.MOD_SET, msg:upper()))
    else
        ToggleMenu()
    end
end

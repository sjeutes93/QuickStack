# 🪙 QuickStack
### *Stop clicking. Start stacking.* · *Schluss mit Klicken. Her mit den Stacks.*

---

## 🇬🇧 English

Tired of buying 20 items one by one, or fighting the quantity popup every time you restock? **QuickStack** lets you grab a **full stack in a single click**.

> ⚡ **Hold `Alt` + Left-click** an item at any vendor, done.

### ✨ Features
- 🛒 **One-click full stacks**: buy a whole stack instantly
- 🧠 **Smart stack size**: detected automatically for every item
- 💰 **Safe buying**: limited by vendor stock and your gold, so no failed purchases
- ⌨️ **Your key, your way**: switch the modifier at any time
- 🪶 **Featherlight**: no frames, no clutter, no performance cost

### ⌨️ Commands
| Command | What it does |
|---|---|
| `/qs` | Shows the current setting |
| `/qs alt` | Use **Alt** + Left-click *(default)* |
| `/qs ctrl` | Use **Ctrl** + Left-click |
| `/qs shift` | Use **Shift** + Left-click |

### 📦 Installation
1. Install via the **CurseForge app**, or copy the `QuickStack` folder to `World of Warcraft/_retail_/Interface/AddOns/` *(Classic: `_classic_` / `_classic_era_`)*
2. Make sure the addon is enabled on the character selection screen
3. Visit a vendor and **Alt + Left-click** an item 🎉

### ❓ Troubleshooting
- **"Incompatible" or "Out of date"?** Tick **Load out of date AddOns** in the AddOns menu
- **Nothing happens?** Type `/reload` and check that the folder is named exactly `QuickStack`
- **Items bought with tokens/currencies:** affordability can't be pre-checked, the game will tell you if it's not enough
- **Found a bug?** Post the Lua error text (e.g. via *BugSack*) in the comments

---

## 🇩🇪 Deutsch

Keine Lust, 20 Gegenstände einzeln zu kaufen oder jedes Mal das Mengenfenster zu bedienen? Mit **QuickStack** kaufst du einen **vollen Stack mit einem einzigen Klick**.

> ⚡ **`Alt` gedrückt halten + Linksklick** auf einen Gegenstand beim Händler, fertig.

### ✨ Funktionen
- 🛒 **Voller Stack per Klick**: sofort einen ganzen Stack kaufen
- 🧠 **Intelligente Stackgröße**: wird für jedes Item automatisch erkannt
- 💰 **Sicher einkaufen**: begrenzt durch Händlerbestand und dein Gold, keine fehlgeschlagenen Käufe
- ⌨️ **Deine Taste**: Modifier jederzeit änderbar
- 🪶 **Federleicht**: keine Fenster, kein Chaos, keine Leistungseinbußen

### ⌨️ Befehle
| Befehl | Wirkung |
|---|---|
| `/qs` | Zeigt die aktuelle Einstellung |
| `/qs alt` | **Alt** + Linksklick *(Standard)* |
| `/qs ctrl` | **Strg** + Linksklick |
| `/qs shift` | **Umschalt** + Linksklick |

### 📦 Installation
1. Über die **CurseForge-App** installieren oder den Ordner `QuickStack` nach `World of Warcraft/_retail_/Interface/AddOns/` kopieren *(Classic: `_classic_` / `_classic_era_`)*
2. Auf dem Charakterbildschirm prüfen, ob das Addon aktiviert ist
3. Zum Händler gehen und **Alt + Linksklick** auf einen Gegenstand 🎉

### ❓ Probleme?
- **„Inkompatibel“ oder „Veraltet“?** Im AddOn-Menü **Veraltete AddOns laden** anhaken
- **Nichts passiert?** `/reload` eingeben und prüfen, ob der Ordner exakt `QuickStack` heißt
- **Items mit Marken/Währungen:** Leistbarkeit kann nicht vorab geprüft werden, das Spiel meldet es, falls es nicht reicht
- **Fehler gefunden?** Lua-Fehlertext (z. B. via *BugSack*) in die Kommentare schreiben



UPDATE // 

# 🪙 QuickStack

**Alt + Left-click at a vendor buys the amount you choose.** A tiny World of Warcraft addon with a per-item amount slider, a draggable minimap button and a built-in bug report.

*Alt + Linksklick beim Händler kauft die Menge, die du einstellst.*

## Features
- One-click buying with a modifier key (Alt, Ctrl or Shift)
- Amount per item, 1-20 via slider, saved per account
- Items are added on their first click or by dragging them from your bags
- Limited by vendor stock and your gold
- Minimap button, draggable along the minimap edge, opens the menu
- Settings tab and bug report tab
- English and German

## Usage
1. Click the coin icon on the minimap, or type `/qs`
2. Set the amount for each item in the **Items** tab
3. At a vendor, hold **Alt** and **left-click** an item

| Command | Description |
|---|---|
| `/qs` | Open the menu |
| `/qs alt` / `ctrl` / `shift` | Set the modifier key |

Items without a saved amount buy a full stack (max. 20) and are added to the list automatically.

## Installation
- **CurseForge:** install via the CurseForge app, or
- **Manually:** copy the `QuickStack` folder (containing `QuickStack.toc` and `QuickStack.lua`) to `World of Warcraft/_retail_/Interface/AddOns/` (Classic: `_classic_` / `_classic_era_`)

If the game says *Incompatible* or *Out of date*, tick **Load out of date AddOns**.

## Reporting bugs
Open an [issue](https://github.com/sjeutes93/QuickStack/issues) and paste the report from the **Bug Report** tab in the menu. Lua error text (e.g. from BugSack) helps a lot.

## Project layout
| File | Purpose |
|---|---|
| `QuickStack.toc` | Addon metadata and supported game versions |
| `QuickStack.lua` | All addon code |
| `.pkgmeta` | Settings for the CurseForge packager |
| `.github/workflows/release.yml` | Builds and publishes a release when a version tag is pushed |

## Releasing
Push a tag such as `v1.1.0`. The workflow packages the addon and creates a GitHub release. For CurseForge uploads, add the `CF_API_KEY` secret and the `X-Curse-Project-ID` line to the `.toc`.

## License
[MIT](LICENSE)

---

# 🇩🇪 Kurzfassung

QuickStack kauft beim Händler mit **Alt + Linksklick** die Menge, die du pro Item einstellst (Regler 1-20). Menü über den Minimap-Button oder `/qs`. Items werden beim ersten Alt-Klick automatisch hinzugefügt oder aus den Taschen ins Menü gezogen. Fehler meldest du über den Reiter **Bug melden** oder ein [GitHub-Issue](https://github.com/sjeutes93/QuickStack/issues).



💛 *Gefällt dir QuickStack? Ein Kommentar oder eine Bewertung hilft, dass andere das Addon finden.*
*Enjoying QuickStack? A comment or rating helps others find it.*

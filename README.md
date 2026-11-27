# 🪙 QuickStack

**Restock in seconds.** Hold **Alt** and left-click an item at a vendor to buy the amount you set for that item. A small World of Warcraft addon with a per-item amount slider, a draggable minimap button, a WoW-style menu and a built-in bug report.

*Nachkaufen in Sekunden: Alt + Linksklick beim Händler kauft die Menge, die du pro Item einstellst.*

## Features
- One-click buying with a modifier key (Alt, Ctrl or Shift)
- Your own amount per item (slider, or type any number up to 1000), saved automatically
- "Top up to" mode: buy only what is missing to reach a target in your bags
- Profiles per character, export and import of your item list
- Optional confirmation before expensive purchases
- Items are added on their first Alt-click, or by dragging them from your bags into the menu
- Never buys more than the vendor has or you can afford
- Price table at the vendor and in tooltips, comparing with the cheapest vendor you have seen (e.g. reputation discounts)
- Draggable minimap button that opens the menu
- Native WoW look: dialog frame, panel buttons, slider bars
- Entry in the game's options (Esc > Options > AddOns), also via `/qs options`
- Uses LibDataBroker / LibDBIcon when available (minimap button collections, broker displays), otherwise its own minimap button
- In-game update notice via version exchange in guild, group and raid (can be switched off)
- Bug report tab that adds recent errors and a debug log; debug mode in the settings
- Settings tab
- English, German, French, Spanish and Russian, no libraries

## Usage
1. Click the coin icon on the minimap, or type `/qs`
2. In the **Items** tab, set the amount for each item
3. At a vendor, hold **Alt** and **left-click** an item

| Command | Description |
|---|---|
| `/qs` | Open or close the menu |
| `/qs options` | Open the game's options entry |
| `/qs alt` / `ctrl` / `shift` | Set the modifier key |

Items without a saved amount buy a full stack (max. 20) on their first Alt-click and are added to the list.

## Installation
- **CurseForge:** install via the CurseForge app, or
- **Manually:** copy the `QuickStack` folder (it must contain `QuickStack.toc` directly) into the `Interface/AddOns` folder of your game version (Retail or Forever) inside your World of Warcraft installation

If the game says *Incompatible* or *Out of date*, tick **Load out of date AddOns**.

## Contributing and support
See [CONTRIBUTING.md](CONTRIBUTING.md) for translations and the code layout, and [SUPPORT.md](SUPPORT.md) for questions.

## Reporting bugs
Open an [issue](https://github.com/sjeutes93/QuickStack/issues) and paste the report from the **Bug Report** tab in the menu. Lua error text (e.g. from BugSack) helps a lot.

## Project layout
| Path | Purpose |
|---|---|
| `QuickStack.toc` | Addon metadata, supported game versions, file list |
| `Locales/` | Translations, one file per language |
| `Core.lua` | Constants, helpers, profiles, debug log, error capture |
| `UI.lua` | UI building blocks in the native WoW look |
| `Buying.lua` | Buying logic and vendor clicks |
| `Prices.lua` | Price tracking, price table, tooltip prices |
| `Launcher.lua` | Minimap button, LibDataBroker / LibDBIcon |
| `Menu.lua`, `Pages/` | Menu window and its pages |
| `Options.lua` | Entry in the game options, key binding |
| `Update.lua` | Update notice |
| `Events.lua` | Events and slash commands |
| `Bindings.xml` | Key binding to open the menu |
| `.pkgmeta` | Settings for the CurseForge packager |
| `.github/` | Release workflow, issue and pull request templates |

## Update notice
Addons cannot access the internet, so QuickStack users exchange their version number through addon messages in guild, party and raid. Set `DOWNLOAD_URL` at the top of `Core.lua` to the page that should be shown in the notice.

## Releasing
Push a tag such as `v1.1.0`. The workflow packages the addon and creates a GitHub release. For automatic CurseForge uploads, add the `CF_API_KEY` secret and the `X-Curse-Project-ID` line to the `.toc`.

## License
[MIT](LICENSE)

---

# 🇩🇪 Kurzfassung

QuickStack kauft beim Händler mit **Alt + Linksklick** die Menge, die du pro Item einstellst (Regler 1-20). Menü über den Minimap-Button oder `/qs`. Neue Items trägst du mit dem ersten Alt-Klick ein oder ziehst sie aus den Taschen ins Menü. Fehler meldest du über den Reiter **Bug melden** oder ein [GitHub-Issue](https://github.com/sjeutes93/QuickStack/issues).

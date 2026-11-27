# Contributing to QuickStack

Thank you for helping! You do not need to be a programmer to contribute.

## Reporting bugs
Open the **Bug Report** tab in the QuickStack menu, click **Create report** and paste the text into a new [issue](https://github.com/sjeutes93/QuickStack/issues). Recent QuickStack errors are added to the report automatically.

## Improving or adding a translation
All texts live in the `Locales/` folder, one file per language:

| File | Language |
|---|---|
| `Locales/enUS.lua` | English (the fallback for everything) |
| `Locales/deDE.lua` | German |
| `Locales/frFR.lua` | French |
| `Locales/esES.lua` | Spanish (also used for esMX) |
| `Locales/ruRU.lua` | Russian |

**Improve a translation:** open the file, change the text on the right of the `=` sign, keep the key on the left unchanged.

**Keep placeholders intact:** `%s`, `%d` and `%%` are filled in by the addon. They must stay in the text, in the same order. Color codes such as `|cffff6060 ... |r` should be kept too.

**Add a new language** (for example Portuguese, `ptBR`):
1. Copy `Locales/enUS.lua` to `Locales/ptBR.lua`.
2. In the new file, replace `ns.locales.enUS` with `ns.locales.ptBR` and translate the texts.
3. Add `Locales\ptBR.lua` to `QuickStack.toc` below the other locale files.

A partly translated file is fine. Missing texts fall back to English.

Test in the game with `/reload`, then open the menu. Send your change as a pull request, or open an issue and paste the translated texts.

Other locale codes: `itIT`, `ptBR`, `koKR`, `zhCN`, `zhTW`.

## Code layout
| File | Purpose |
|---|---|
| `Core.lua` | constants, helpers, profiles, debug log, error capture |
| `UI.lua` | UI building blocks in the native WoW look |
| `Buying.lua` | buying logic and vendor clicks |
| `Prices.lua` | price tracking, price table, tooltip prices |
| `Launcher.lua` | minimap button, LibDataBroker / LibDBIcon |
| `Menu.lua`, `Pages/` | menu window and its pages |
| `Options.lua` | entry in the game options, key binding |
| `Update.lua` | update notice |
| `Events.lua` | events and slash commands |

Files share data through the `ns` table (the second value every file receives with `local ADDON, ns = ...`).

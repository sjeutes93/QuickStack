## 1.6.0
- New: the bug report now contains recent QuickStack errors, a short debug log and a list of other relevant addons. A "Clear log" button empties them
- New: debug mode in the settings shows purchase details in the chat
- Errors are captured without hiding them from other error displays such as BugSack
- Under the hood: the code is split into modules and the translations live in one file per language, so they are easier to maintain and improve (no change for players)

## 1.5.0
- New: entry in the game's options window (Esc > Options > AddOns > QuickStack) with the most important settings and a button to open the menu. Also available with /qs options
- New: uses LibDataBroker and LibDBIcon when they are available, so the button also appears in minimap button collections and broker displays; otherwise QuickStack keeps its own minimap button

## 1.4.0
- New: in-game update notice. When another QuickStack user with a newer version is in your guild, group or raid, you get a message with the download link, and the menu shows a hint until you update. Can be switched off in the settings.

## 1.3.0
- New: "Top up to" mode: buy only what is missing to reach a target amount in your bags
- New: amounts above 20, type any number up to 1000 (large amounts are bought in stack-sized steps)
- New: profiles per character, with create, duplicate and delete
- New: export and import of your item list
- New: optional confirmation before expensive purchases
- New: number of items already in your bags is shown in the list
- New: price table shows the price for the amount you buy, how old the comparison is and how much you save
- New: key binding to open the menu (Key Bindings > AddOns)
- New: French, Spanish and Russian translations
- Improved: minimap button follows square and other non-round minimaps

## 1.2.0
- New: price table next to the vendor window for the items on your list, with a comparison to the cheapest vendor you have seen (for example a capital city with a reputation discount)
- New: "Prices" tab in the menu with all recorded vendors per item
- New: price lines in item tooltips (can be switched off in the settings)
- Fixed: the X button in the top right corner now reliably closes the menu
- Improved: classic WoW icon frames around items and a native delete icon

## 1.1.0
- New: draggable minimap button that opens the QuickStack menu
- New: menu in the native WoW look (dialog frame, panel buttons, slider bars)
- New: set the purchase amount (1-20) per item with a slider; saved per account
- New: items are added automatically on first Alt-click, or by dragging them from your bags
- New: settings tab (modifier key, auto-add, minimap button)
- New: bug report tab that creates a copyable report
- /qs now opens the menu

## 1.0.0
- Initial release: Alt + Left-click buys a full stack at a vendor

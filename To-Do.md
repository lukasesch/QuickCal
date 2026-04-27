# QuickCal — iOS 26 Update Plan

---

## ✅ Completed

### Search bar fix (`AddTrackedFoodView`)
- **Root cause:** `TabView` + `NavigationStack` + `.sheet` combination swallows `.searchable` in iOS 26
- **Fix:** Replaced `TabView` with a segmented `Picker` controlling `if/else` List blocks — no more `TabView` interference
- Also added `filterMealItems(by:)` to `AddTrackedFoodViewModel` so meal tab search works too

### Deprecation & API fixes

**`exit(0)` removed (`AdvancedSettingsView` + `Persistence.swift`)**
- Old code called `deletePersistentStore()` (which destroyed the SQLite file but never reloaded) and then `exit(0)` to force-restart
- Fixed `deletePersistentStore()` in `Persistence.swift` to properly reload the persistent store and re-seed default food
- "App zurücksetzen" button now sets `onboardingDone = false`, which routes back to `WelcomeView` with a fresh Core Data stack — no restart needed

**`.onChange(of:)` old syntax fixed**
- Updated all single-parameter `.onChange` closures to two-parameter `{ oldValue, newValue in }` syntax (iOS 17+)
- Affected: `MainView`, `AddTrackedFoodView`, `OpenFoodFactsView`, `CreateMealIngredientsView`

**`UILabel.appearance()` removed (`CreateFoodPanelView`)**
- Removed entire `init()` block containing UIKit appearance proxy — unreliable with SwiftUI in iOS 26

**`Alert()` deprecated constructor fixed**
- Replaced deprecated `Alert()` constructors with modern `.alert(_:isPresented:presenting:actions:message:)` in `EditProfileView` and `ProfileView`

**Custom overlay alerts migrated to `.sheet(item:)`**
- All hand-rolled `overlay(Group { ... })` alert overlays replaced with native `.sheet(item:)` across:
  - `AddTrackedFoodView` — 3 sheets (food add, meal add, food edit via long-press)
  - `MainView` — 1 sheet (edit tracked food portion)
  - `OpenFoodFactsView` — 1 sheet
  - `CreateMealIngredientsView` — 1 sheet
  - `BarCodeView` — 1 sheet (was also broken; fixed alongside compiler errors)
- Alert structs updated: removed `isPresented: Binding<Bool>`, removed `ZStack`/`Color.black` backdrop, `foodItem`/`mealItem` now non-optional

### Sheet styling improvements
- `CustomAlertEditFoodAttributes` (long-press food edit in `AddTrackedFoodView`): uses `.presentationDetents([.medium, .large])` + `.scrollContentBackground(.hidden)` + `.background(.clear)` so it renders as Liquid Glass instead of opaque full-screen
- `CustomAlertEdit` (tap food in `MainView` list): redesigned with centered prominent food name (`.title2`/`.bold`), plain macro text row, single "Ändern" action button; content centered so empty safe-area space at top feels balanced

---

## 🔲 Still To Do

### Phase 2: Liquid Glass visual polish (required for App Store, April 2026)
Once recompiled with Xcode 26 SDK, Lists and Forms inside sheets will have opaque backgrounds that block Liquid Glass.

| View | Fix needed |
|---|---|
| `AddTrackedFoodView` (sheet) | `.scrollContentBackground(.hidden)` on List |
| `OpenFoodFactsView` | `.scrollContentBackground(.hidden)` on List |
| `CreateMealIngredientsView` | `.scrollContentBackground(.hidden)` on List |
| `MainView` settings sheet | `.scrollContentBackground(.hidden)` on List |
| All pushed `NavigationStack` destinations inside sheets | `.containerBackground(.clear, for: .navigation)` |

### Phase 4: Minimum deployment target
- Update project deployment target to iOS 26 in Xcode project settings
- iOS 26 minimum hardware: iPhone 11 (A13) — dropped iPhone XR/XS/XS Max (A12)
- Remove any conditional code for older devices if present

### Phase 5: New iOS 26 APIs (optional)
- **`searchToolbarBehavior(.minimized)`** — collapse search to toolbar icon when not needed
- **`ToolbarSpacer`** — better keyboard toolbar control in `CreateFoodPanelView` / `CreateMealPanelView`
- **Section index labels** — useful for long food list in `AddTrackedFoodView`
- **`Tab(role: .search)`** — if ever redesigning to a tab-based search experience

---

## Sources

- [SwiftUI Search Enhancements in iOS and iPadOS 26](https://nilcoalescing.com/blog/SwiftUISearchEnhancementsIniOSAndiPadOS26/)
- [Liquid Glass Sheets with NavigationStack and Form](https://nilcoalescing.com/blog/LiquidGlassSheetsWithNavigationStackAndForm/)
- [What's new in SwiftUI for iOS 26 – Hacking with Swift](https://www.hackingwithswift.com/articles/278/whats-new-in-swiftui-for-ios-26)
- [iOS 26 Developer Guide](https://www.index.dev/blog/ios-26-developer-guide)

# Project Spec: Bloom & Brew ☕️

**Aesthetic:** Minimalist, Soft-UI, Pastel Palette
**Platform:** iOS 18+ (SwiftUI)

## 1. Vision & Core Vibe

A high-end, calm companion for an espresso-focused lifestyle. The app should feel like a "breath of fresh air"—no cluttered menus, just smooth transitions, rounded corners, and soft colors.

## 2. Visual Identity (Design System)

* **Background:** `#F5E6CA` (Soft Milk Tea / Latte)
* **Accent 1:** `#E7CCCC` (Dusty Rose / Espresso)
* **Accent 2:** `#D4E2D4` (Pale Mint / Steamed Milk)
* **Typography:** System `Rounded` font. Use `.largeTitle` for headers with heavy tracking for a premium feel.
* **Components:** Cards should have a `cornerRadius` of 28pt.
* Use `Material.ultraThin` (Glassmorphism) for overlays.

## 3. Core Features

### A. The Espresso Bar (Recipes)

Provide a quick-reference guide for espresso-based drinks. Each recipe card should show a visual ratio bar.

* **Latte:** 1 shot espresso | 8–10 oz steamed milk | Thin foam (Ratio 1:4)
* **Flat White:** 2 shots espresso (ristretto) | 4–6 oz micro-foam (Ratio 1:3)
* **Cappuccino:** 1 shot espresso | Equal parts milk & foam (Ratio 1:1:1)
* **Cortado:** 1 shot espresso | 1 part steamed milk (Ratio 1:1)

### B. The Coworking Counter

A simple, satisfying way to track caffeine intake during the work day.

* Large, centered counter on the Home View.
* Buttons: A prominent `+` and a smaller `-` button.
* **Persistence:** Use `@AppStorage` so the count survives app restarts.

### C. Sensory Feedback

* **Haptics:** Trigger `.selection` haptics when tapping recipes and `.success` when incrementing the cup counter.
* **Animations:** Use `.spring()` animations for all view transitions and button presses to keep the "vibe" bouncy and light.

## 4. Technical Architecture

* **Framework:** SwiftUI (Modern concurrency/Swift 6).
* **Data:** No external APIs needed. Hard-code the recipes into a `Recipe` struct.
* **Persistence:** `@AppStorage("dailyCount")` for the counter.
* **File Structure:**
  * `Theme.swift`: Colors and ViewModifiers.
  * `Models.swift`: Recipe data structures.
  * `HomeView.swift`: Main dashboard & Coworking counter.
  * `RecipeDetailView.swift`: The visual ratio and instructions for each drink.

## 5. Implementation Roadmap for Cursor

1. **Step 1:** Define the `Theme` and `Color` extensions.
2. **Step 2:** Create the `HomeView` with the pastel background and the Cup Counter.
3. **Step 3:** Implement the `Recipe` list as horizontal scrolling cards.
4. **Step 4:** Build the `RecipeDetailView` that pops up with a beautiful "Ratio Bar" graphic.

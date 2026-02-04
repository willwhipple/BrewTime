//
//  Models.swift
//  BrewTime
//
//  Recipe data structures and hard-coded espresso recipes.
//

import Foundation

// MARK: - Ratio segment for the ratio bar

struct RatioComponent: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Int
}

// MARK: - Recipe (Identifiable for sheet(item:))

struct Recipe: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let ratioDescription: String
    let ratioComponents: [RatioComponent]
    let instructions: [String]
}

// MARK: - Hard-coded recipes

extension Recipe {
    static let allRecipes: [Recipe] = [
        .latte,
        .flatWhite,
        .cappuccino,
        .cortado
    ]

    static let latte = Recipe(
        name: "Latte",
        description: "1 shot espresso · 8–10 oz steamed milk · Thin foam",
        ratioDescription: "1:4",
        ratioComponents: [
            RatioComponent(label: "Espresso", value: 1),
            RatioComponent(label: "Milk", value: 4)
        ],
        instructions: [
            "Pull 1 shot of espresso.",
            "Steam 8–10 oz milk with thin foam.",
            "Pour milk over espresso."
        ]
    )

    static let flatWhite = Recipe(
        name: "Flat White",
        description: "2 shots (ristretto) · 4–6 oz micro-foam",
        ratioDescription: "1:3",
        ratioComponents: [
            RatioComponent(label: "Ristretto", value: 1),
            RatioComponent(label: "Micro-foam", value: 3)
        ],
        instructions: [
            "Pull 2 ristretto shots.",
            "Steam 4–6 oz milk to silky micro-foam.",
            "Pour and integrate."
        ]
    )

    static let cappuccino = Recipe(
        name: "Cappuccino",
        description: "1 shot · Equal parts milk & foam",
        ratioDescription: "1:1:1",
        ratioComponents: [
            RatioComponent(label: "Espresso", value: 1),
            RatioComponent(label: "Milk", value: 1),
            RatioComponent(label: "Foam", value: 1)
        ],
        instructions: [
            "Pull 1 shot of espresso.",
            "Steam milk for equal parts milk and foam.",
            "Combine in equal portions."
        ]
    )

    static let cortado = Recipe(
        name: "Cortado",
        description: "1 shot · 1 part steamed milk",
        ratioDescription: "1:1",
        ratioComponents: [
            RatioComponent(label: "Espresso", value: 1),
            RatioComponent(label: "Milk", value: 1)
        ],
        instructions: [
            "Pull 1 shot of espresso.",
            "Add equal part steamed milk (no foam)."
        ]
    )
}

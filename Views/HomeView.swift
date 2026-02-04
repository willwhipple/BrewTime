//
//  HomeView.swift
//  BrewTime
//
//  Main dashboard: Coworking Counter and horizontal recipe cards. Sheet for recipe detail.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("dailyCount") private var dailyCount: Int = 0
    @State private var selectedRecipe: Recipe?
    @State private var isAnimatingCounter = false

    private var backgroundColor: Color { Theme.background(for: colorScheme) }
    private var primaryText: Color { Theme.primaryText(for: colorScheme) }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                Text("BrewTime")
                    .themeLargeTitle()
                    .foregroundStyle(primaryText)
                    .padding(.top, 20)

                // Coworking Counter
                VStack(spacing: 16) {
                    Text("\(dailyCount)")
                        .font(.system(size: 72, weight: .light))
                        .fontDesign(.rounded)
                        .foregroundStyle(primaryText)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: dailyCount)
                        .scaleEffect(isAnimatingCounter ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimatingCounter)

                    Text("cups today")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Theme.secondaryText(for: colorScheme))

                    HStack(spacing: 24) {
                        // Minus button (smaller)
                        Button {
                            if dailyCount > 0 {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    dailyCount -= 1
                                }
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(Theme.accent1(for: colorScheme))
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.plain)
                        .disabled(dailyCount == 0)
                        .opacity(dailyCount == 0 ? 0.5 : 1)

                        // Plus button (prominent)
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                dailyCount += 1
                                isAnimatingCounter = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isAnimatingCounter = false
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(Theme.accent2(for: colorScheme))
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)

                // Recipe cards (horizontal)
                VStack(alignment: .leading, spacing: 12) {
                    Text("The Espresso Bar")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(primaryText)
                        .padding(.horizontal, 4)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(Recipe.allRecipes) { recipe in
                                RecipeCardView(recipe: recipe) {
                                    let generator = UISelectionFeedbackGenerator()
                                    generator.selectionChanged()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedRecipe = recipe
                                    }
                                }
                                .environment(\.colorScheme, colorScheme)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .frame(height: 140)
                }

                Spacer(minLength: 0)
            }
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Recipe card (tappable)

struct RecipeCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let recipe: Recipe
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.primaryText(for: colorScheme))
                Text(recipe.ratioDescription)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Theme.secondaryText(for: colorScheme))
            }
            .frame(width: 140, alignment: .leading)
            .padding(20)
            .themeCard()
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    HomeView()
}

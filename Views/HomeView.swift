//
//  HomeView.swift
//  BrewTime
//
//  Main dashboard: Coworking Counter and 2-column recipe grid. Sheet for recipe detail.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(DailyCupLog.storageKey) private var rawTimestamps: String = "[]"
    @State private var selectedRecipe: Recipe?
    @State private var isAnimatingCounter = false
    @State private var cautionMessage: String?
    @State private var showCautionAlert = false
    private var todayTimestamps: [Date] {
        DailyCupLog.todayTimestamps(from: rawTimestamps)
    }

    private var dailyCount: Int { todayTimestamps.count }
    private var primaryText: Color { Theme.primaryText(for: colorScheme) }

    private static let coffeeQuote = "Coffee is a language in itself. — Jackie Chan"

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(spacing: 0) {
                // Header
                Text("BrewTime")
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .foregroundStyle(primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 24)

                // 32pt vertical space between counter and recipe list
                Spacer()
                    .frame(height: 32)

                // Coworking Counter (no glass container)
                VStack(spacing: 16) {
                    Text("\(dailyCount)")
                        .font(.system(size: 72, weight: .medium))
                        .fontDesign(.rounded)
                        .foregroundStyle(primaryText)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: dailyCount)
                        .scaleEffect(isAnimatingCounter ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimatingCounter)

                    Text("cups today")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)

                    if let summary = CoffeeRules.dailySummary(cupTimestamps: todayTimestamps), !todayTimestamps.isEmpty {
                        Text(summary)
                            .font(.body)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                            .lineSpacing(8)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 24) {
                        Button {
                            if dailyCount > 0 {
                                let sorted = todayTimestamps.sorted(by: <)
                                let newList = Array(sorted.dropLast())
                                rawTimestamps = DailyCupLog.encode(newList)
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    isAnimatingCounter = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    isAnimatingCounter = false
                                }
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .disabled(dailyCount == 0)
                        .opacity(dailyCount == 0 ? 0.5 : 1)

                        Button {
                            let now = Date()
                            var list = todayTimestamps
                            list.append(now)
                            rawTimestamps = DailyCupLog.encode(list)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                isAnimatingCounter = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isAnimatingCounter = false
                            }
                            if let warning = CoffeeRules.warning(cupTimestamps: list, now: now) {
                                cautionMessage = warning
                                showCautionAlert = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .semibold))
                                .frame(width: 64, height: 64)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.accent2(for: colorScheme))
                        .buttonBorderShape(.roundedRectangle(radius: 16))
                    }
                }
                .padding(.vertical, 16)

                // Recipe cards (2-column grid – button-like tiles)
                VStack(alignment: .leading, spacing: 16) {
                    Text("The Espresso Bar")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(primaryText)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Recipe.allRecipes) { recipe in
                            RecipeCardView(recipe: recipe) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    selectedRecipe = recipe
                                }
                            }
                            .environment(\.colorScheme, colorScheme)
                        }
                    }
                }

                // Coffee quote at bottom
                Text(Self.coffeeQuote)
                    .font(.footnote)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                    .padding(.bottom, 16)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
        }
        .sensoryFeedback(.selection, trigger: dailyCount)
        .sensoryFeedback(.selection, trigger: selectedRecipe?.id)
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Heads up", isPresented: $showCautionAlert) {
            Button("OK", role: .cancel) {
                cautionMessage = nil
            }
        } message: {
            Text(cautionMessage ?? "")
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
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.primaryText(for: colorScheme))
                Text(recipe.ratioDescription)
                    .font(.body)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .lineSpacing(8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Theme.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.secondaryText(for: colorScheme).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 8, x: 0, y: 2)
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

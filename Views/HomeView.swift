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

                    // Optional daily summary
                    if let summary = CoffeeRules.dailySummary(cupTimestamps: todayTimestamps), !todayTimestamps.isEmpty {
                        Text(summary)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Theme.secondaryText(for: colorScheme))
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 24) {
                        // Minus button (smaller) – filled circle, contrasting icon
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
                                .foregroundStyle(Theme.primaryText(for: colorScheme))
                                .frame(width: 44, height: 44)
                                .background(Theme.accent1(for: colorScheme))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(dailyCount == 0)
                        .opacity(dailyCount == 0 ? 0.5 : 1)

                        // Plus button (prominent) – filled circle, contrasting icon
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
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
                                .foregroundStyle(Theme.primaryText(for: colorScheme))
                                .frame(width: 64, height: 64)
                                .background(Theme.accent2(for: colorScheme))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)

                // Recipe cards (2-column grid – all four visible)
                VStack(alignment: .leading, spacing: 12) {
                    Text("The Espresso Bar")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(primaryText)
                        .padding(.horizontal, 4)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
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
                }

                Spacer(minLength: 0)
            }
        }
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
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.primaryText(for: colorScheme))
                Text(recipe.ratioDescription)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Theme.secondaryText(for: colorScheme))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

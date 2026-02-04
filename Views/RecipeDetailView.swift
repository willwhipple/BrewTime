//
//  RecipeDetailView.swift
//  BrewTime
//
//  Sheet content: recipe name, ratio bar (stacked segments), instructions, dismiss.
//

import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    let recipe: Recipe

    private var backgroundColor: Color { Theme.background(for: colorScheme) }
    private var primaryText: Color { Theme.primaryText(for: colorScheme) }
    private var secondaryText: Color { Theme.secondaryText(for: colorScheme) }
    private var accent1: Color { Theme.accent1(for: colorScheme) }
    private var accent2: Color { Theme.accent2(for: colorScheme) }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                // Dismiss bar (optional Material)
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(secondaryText)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(recipe.name)
                            .themeLargeTitle()
                            .foregroundStyle(primaryText)

                        Text(recipe.description)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(secondaryText)

                        // Ratio bar
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ratio \(recipe.ratioDescription)")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundStyle(secondaryText)

                            RatioBarView(
                                components: recipe.ratioComponents,
                                accent1: accent1,
                                accent2: accent2
                            )
                            .frame(height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How to make")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(primaryText)

                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(index + 1).")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundStyle(accent1)
                                        .frame(width: 20, alignment: .leading)
                                    Text(step)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(secondaryText)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

// MARK: - Ratio bar (stacked segments)

struct RatioBarView: View {
    let components: [RatioComponent]
    let accent1: Color
    let accent2: Color

    private var total: Int {
        components.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(Array(components.enumerated()), id: \.element.id) { index, component in
                    let width = total > 0 ? geo.size.width * CGFloat(component.value) / CGFloat(total) : 0
                    RoundedRectangle(cornerRadius: 0)
                        .fill(index % 2 == 0 ? accent1 : accent2)
                        .frame(width: max(0, width))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RecipeDetailView(recipe: .latte)
}

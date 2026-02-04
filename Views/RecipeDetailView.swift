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
    @State private var dismissTrigger = false

    private var primaryText: Color { Theme.primaryText(for: colorScheme) }
    private var secondaryText: Color { Theme.secondaryText(for: colorScheme) }
    private var accent1: Color { Theme.accent1(for: colorScheme) }
    private var accent2: Color { Theme.accent2(for: colorScheme) }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        dismissTrigger.toggle()
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
                .padding(.top, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(recipe.name)
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(primaryText)

                        Text(recipe.description)
                            .font(.body)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                            .lineSpacing(8)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ratio \(recipe.ratioDescription)")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            RatioBarView(
                                components: recipe.ratioComponents,
                                accent1: accent1,
                                accent2: accent2
                            )
                            .frame(height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("How to make")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(primaryText)

                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1).")
                                        .font(.body)
                                        .fontDesign(.rounded)
                                        .fontWeight(.medium)
                                        .foregroundStyle(accent1)
                                        .frame(width: 24, alignment: .leading)
                                    Text(step)
                                        .font(.body)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                        .lineSpacing(8)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 32)
                }
            }
            .padding(.horizontal, 24)
        }
        .sensoryFeedback(.selection, trigger: dismissTrigger)
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
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    RecipeDetailView(recipe: .latte)
}

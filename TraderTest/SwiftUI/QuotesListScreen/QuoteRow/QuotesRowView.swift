//
//  QuotesRowView.swift
//  TraderTest
//
//  Created by Asan Ametov on 10.03.2026.
//

import SwiftUI
import Combine

struct QuotesRowView: View {
    // статичное (не меняется от тиков)
    let ticker: String
    let name: String?
    let iconURL: String?

    // динамика (часто меняется)
    @ObservedObject var live: QuoteLiveVM

    var body: some View {
        HStack(spacing: 12) {
            LeftStaticPart(ticker: ticker, name: name, iconURL: iconURL) //обновляется только от добавления картинки и name
            Spacer(minLength: 8)
            RightLivePart(live: live) // обновляется часто
        }
    }
}

private struct LeftStaticPart: View, Equatable {
    let ticker: String
    let name: String?
    let iconURL: String?

    static func ==(l: Self, r: Self) -> Bool {
        l.ticker == r.ticker && l.name == r.name && l.iconURL == r.iconURL
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8) {
                if let iconURL {
                    LogoAsyncImage(placeholder: { EmptyView() }, urlString: iconURL, minSide: 5) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(maxWidth: 24, maxHeight: 24) 
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .id(iconURL)
                }
                Text(ticker).font(.system(size: 18, weight: .semibold))
            }
            if let name, !name.isEmpty {
                Text(name)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

private struct RightLivePart: View {
    @ObservedObject var live: QuoteLiveVM

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ChangeBadgeView(
                text: live.changePercentText,
                textColor: changeTextColor,
                bg: highlightBackground
            )
            Text(live.priceText)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.black)
        }
    }

    private var changeTextColor: Color {
        switch live.highlight {
        case .down, .up: return .white
        case .none:
            if live.isPositive { return Color(AppColors.up) }
            if live.isNegative { return Color(AppColors.down) }
            return Color(AppColors.neutral)
        }
    }

    private var highlightBackground: Color {
        switch live.highlight {
        case .down: return Color(AppColors.highlightDown)
        case .up: return Color(AppColors.highlightUp)
        case .none: return .clear
        }
    }
}

private struct ChangeBadgeView: View, Equatable {
    let text: String
    let textColor: Color
    let bg: Color

    static func ==(l: Self, r: Self) -> Bool {
        l.text == r.text && l.textColor == r.textColor && l.bg == r.bg
    }

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold, design: .monospaced))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .foregroundStyle(textColor)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

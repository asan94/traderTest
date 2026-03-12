//
//  QuotesStore.swift
//  TraderTest
//
//  Created by Asan Ametov on 12.03.2026.
//

import SwiftUI
import Combine

@MainActor
final class QuotesStore: ObservableObject {

    struct Row: Identifiable, Hashable {
        var id: String { ticker }
        let ticker: String
        var name: String?
        var iconURL: String?
    }

    @Published var rows: [Row] = []
    private var liveByTicker: [String: QuoteLiveVM] = [:]
    func setRows(_ newRows: [Row]) {
        rows = newRows
        let tickers = Set(newRows.map(\.ticker))
        liveByTicker = liveByTicker.filter { tickers.contains($0.key) }
    }

    func updateStatic(ticker: String, name: String?, iconURL: String?) {
        guard let index = rows.firstIndex(where: {$0.id == ticker }) else {  return }
        var row = rows[index]
        var changed = false
        if row.name != name {
            row.name = name
            changed = true
        }
        if row.iconURL != iconURL {
            row.iconURL = iconURL
            changed = true
        }
        guard changed else { return }
        rows[index] = row
    }
    
    func live(for ticker: String) -> QuoteLiveVM {
        if let vm = liveByTicker[ticker] { return vm }
        let vm = QuoteLiveVM()
        liveByTicker[ticker] = vm
        return vm
    }

    func applyTick(
        ticker: String,
        priceText: String,
        changePercentText: String,
        highlight: QuoteLiveVM.Highlight,
        isPositive: Bool,
        isNegative: Bool
    ) {
        live(for: ticker).update(
            priceText: priceText,
            changePercentText: changePercentText,
            highlight: highlight,
            isPositive: isPositive,
            isNegative: isNegative
        )
    }
}

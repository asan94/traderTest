//
//  QuotesListCellViewModel.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import Foundation

nonisolated struct QuoteCellViewModel: Hashable, @unchecked Sendable {

    enum Highlight: Hashable { case none, up, down }
    let ticker: String
    let name: String?
    let exchange: String?
    let last: Double
    let prevClose: Decimal
    let minStep: Decimal
    let priceText: String
    let changePercentText: String
    let change: Decimal
    let lastTradeTime: String
    let isPositive: Bool
    let isNegative: Bool
    let iconURL: String?
    let tickerText: String
    nonisolated let highlight: Highlight

    init(quote: QuoteDM, highlight: Highlight) {
        self.ticker = quote.ticker
        self.name = [quote.lastTradeReferance, quote.name].compactMap{$0}.joined(separator: " | ")
        self.exchange = quote.lastTradeReferance
        self.last = quote.lastTradePrice ?? 0
        self.tickerText = quote.ticker.replacingOccurrences(of: ("." + (quote.lastTradeReferance ?? "")), with: "")

        let close = Decimal(quote.prevClosePrice ?? 0)
        let minStep = Decimal(quote.minStep ?? 0)
        
        self.prevClose = close
        self.minStep = minStep
        self.highlight = highlight
            
        let change = Decimal(quote.change ?? 0)
        self.change = change
        let lastRounded = Decimal(self.last).rounded(toStep: minStep)
        let chPointsRounded = change.rounded(toStep: minStep)
        let lastText = lastRounded.asString(maxFractionDigits: 6)
        let changePoints = chPointsRounded.asSignedString(maxFractionDigits: 6)
        if chPointsRounded != 0 {
            self.priceText = "\(lastText) (\(changePoints))"
        } else {
            self.priceText = "\(lastText) - "
        }
        let percent = Decimal(quote.prevClosePrice ?? 0.00)
        self.changePercentText = percent.asSignedString(maxFractionDigits: 2) + "%"
        self.isPositive = change > 0
        self.isNegative = change < 0
        let tickerIconUrl =  "https://tradernet.com/logos/get-logo-by-ticker?ticker=\(quote.ticker.lowercased())"
        self.iconURL = tickerIconUrl
        self.lastTradeTime = quote.ltt
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ticker)
        hasher.combine(lastTradeTime)
    }

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.ticker == rhs.ticker) && (lhs.lastTradeTime == rhs.lastTradeTime)
    }
}


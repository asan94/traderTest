//
//  QuoteDM.swift
//  TraderTest
//
//  Created by Asan Ametov on 27.02.2026.
//

import Foundation

struct QuotesResponse: Decodable {
    let q: QuoteDM
}

nonisolated struct QuoteDM: Codable {
    var ticker: String
    let lastTradePrice: Double?
    let prevClosePrice: Double?
    let lastTradeReferance: String?
    let name: String?
    let change: Double?
    let minStep: Double?
    var hasChanges:Bool? = false
    var ltt: String
    enum CodingKeys: String, CodingKey {
        case ticker = "c"
        case lastTradePrice = "ltp"
        case prevClosePrice = "pcp"
        case lastTradeReferance = "ltr"
        case name = "name"
        case change = "chg"
        case minStep = "min_step"
        case ltt
    }
    
    func diff(from old: QuoteDM) -> QuoteDM {
        let ticker = QuoteDM(ticker: old.ticker,
                lastTradePrice: lastTradePrice ?? old.lastTradePrice,
                prevClosePrice: prevClosePrice ?? old.prevClosePrice,
                lastTradeReferance: lastTradeReferance ?? old.lastTradeReferance,
                name: name ?? old.name,
                change: change ?? old.change,
                minStep: minStep ?? old.minStep,
                hasChanges: change != nil,
                ltt: ltt)
        return ticker
    }
    
}


extension QuoteDM: @unchecked Sendable {}
extension QuoteDM: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ticker)
    }
    
    nonisolated public static func == (lhs: QuoteDM, rhs: QuoteDM) -> Bool {
        lhs.ticker == rhs.ticker
    }
}

extension QuoteDM {
    var changePercent: Double? {
        guard let ltp = lastTradePrice, let pcp = prevClosePrice, pcp != 0 else { return nil }
        return (ltp - pcp) / pcp * 100
    }

    var isPositive: Bool { (change ?? 0) > 0 }
    var isNegative: Bool { (change ?? 0) < 0 }

    var priceText: String {
        let minStep = Decimal(self.minStep ?? 0)
        let change = Decimal(change ?? 0)
        let chPointsRounded = change.rounded(toStep: minStep)
        let lastRounded = Decimal(lastTradePrice ?? 0).rounded(toStep: minStep)
        let lastText = lastRounded.asString(maxFractionDigits: 6)
        let changePoints = chPointsRounded.asSignedString(maxFractionDigits: 6)
        if chPointsRounded != 0 {
            return "\(lastText) (\(changePoints))"
        } else {
            return "\(lastText) - "
        }
    }

    var changePercentText: String {
        let percent = Decimal(prevClosePrice ?? 0.00)
        return percent.asSignedString(maxFractionDigits: 2) + "%"
    }
    
    var iconURL: String? {
       "https://tradernet.com/logos/get-logo-by-ticker?ticker=\(ticker.lowercased())"
    }
}
//self.ticker = quote.ticker
//self.name = [quote.lastTradeReferance, quote.name].compactMap{$0}.joined(separator: " | ")
//self.exchange = quote.lastTradeReferance
//self.last = quote.lastTradePrice ?? 0
//self.tickerText = quote.ticker.replacingOccurrences(of: ("." + (quote.lastTradeReferance ?? "")), with: "")
//
//let close = Decimal(quote.prevClosePrice ?? 0)
//let minStep = Decimal(quote.minStep ?? 0)
//
//self.prevClose = close
//self.minStep = minStep
//self.highlight = highlight
//    
//let change = Decimal(quote.change ?? 0)
//self.change = change
//let lastRounded = Decimal(self.last).rounded(toStep: minStep)
//let chPointsRounded = change.rounded(toStep: minStep)
//let lastText = lastRounded.asString(maxFractionDigits: 6)
//let changePoints = chPointsRounded.asSignedString(maxFractionDigits: 6)
//if chPointsRounded != 0 {
//    self.priceText = "\(lastText) (\(changePoints))"
//} else {
//    self.priceText = "\(lastText) - "
//}
//let percent = Decimal(quote.prevClosePrice ?? 0.00)
//self.changePercentText = percent.asSignedString(maxFractionDigits: 2) + "%"
//
//self.lastTradeTime = quote.ltt

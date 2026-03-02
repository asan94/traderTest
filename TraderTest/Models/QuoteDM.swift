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

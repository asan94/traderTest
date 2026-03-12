//
//  QuoteRowStatic.swift
//  TraderTest
//
//  Created by Asan Ametov on 12.03.2026.
//

import Foundation

struct QuoteRowStatic: Identifiable, Hashable {
    var id: String { ticker }
    let ticker: String
    let tickerText: String
    let name: String?
    let iconURL: String
}

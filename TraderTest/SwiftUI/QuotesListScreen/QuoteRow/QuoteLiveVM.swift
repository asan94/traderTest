//
//  QuoteLiveVM.swift
//  TraderTest
//
//  Created by Asan Ametov on 12.03.2026.
//

import SwiftUI
import Combine

@MainActor
final class QuoteLiveVM: ObservableObject {
    enum Highlight { case none, up, down }

    @Published private(set) var priceText = ""
    @Published private(set) var changePercentText = ""
    @Published private(set) var highlight: Highlight = .none
    @Published private(set) var isPositive = false
    @Published private(set) var isNegative = false

    func update(priceText: String,
                changePercentText: String,
                highlight: Highlight,
                isPositive: Bool,
                isNegative: Bool) {
        if self.priceText != priceText { self.priceText = priceText }
        if self.changePercentText != changePercentText { self.changePercentText = changePercentText }
        if self.highlight != highlight { self.highlight = highlight }
        if self.isPositive != isPositive { self.isPositive = isPositive }
        if self.isNegative != isNegative { self.isNegative = isNegative }
    }
}


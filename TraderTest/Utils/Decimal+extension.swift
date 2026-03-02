//
//  Decimal+extension.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import Foundation

extension Decimal {
    nonisolated func rounded(toStep step: Decimal) -> Decimal {
        guard step > 0 else { return self }
        // округление до кратного step: round(self/step)*step
        var value = self
        var s = step
        var q = Decimal()
        NSDecimalDivide(&q, &value, &s, .plain)

        var rq = Decimal()
        NSDecimalRound(&rq, &q, 0, .plain)

        var res = Decimal()
        NSDecimalMultiply(&res, &rq, &s, .plain)
        return res
    }

    nonisolated func asString(maxFractionDigits: Int = 6) -> String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US_POSIX")
        nf.decimalSeparator = "."
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = maxFractionDigits
        return nf.string(from: self as NSDecimalNumber) ?? "\(self)"
    }

    nonisolated func asSignedString(maxFractionDigits: Int = 6) -> String {
        let s = asString(maxFractionDigits: maxFractionDigits)
        if self > 0 { return "+\(s)" }
        return s
    }
}

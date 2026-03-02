//
//  PaddingLabel.swift
//  TraderTest
//
//  Created by Asan Ametov on 01.03.2026.
//

import UIKit

class PaddingLabel: UILabel {

    var paddingLeft: CGFloat = 0
    var paddingRight: CGFloat = 0
    var paddingTop: CGFloat = 0
    var paddingBottom: CGFloat = 0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: paddingTop,
            left: paddingLeft,
            bottom: paddingBottom,
            right: paddingRight
        )
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += paddingLeft + paddingRight
        size.height += paddingTop + paddingBottom
        return size
    }
}

//
//  DataAssetns+extension.swift
//  TraderTest
//
//  Created by Asan Ametov on 27.02.2026.
//

import UIKit

extension NSDataAsset {
    
    enum DataAssetAlias: String, CaseIterable {
        case tickers = "TickerDM"
    }
    
    convenience init?(_ alias: DataAssetAlias){
        self.init(name:alias.rawValue)
    }
}

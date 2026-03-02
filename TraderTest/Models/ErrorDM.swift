//
//  ErrorDM.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import Foundation

struct ErrorDM: Decodable {
    let code: Int
    let error: String
    let errMsg: String
}

extension ErrorDM {
    func asNSError() -> NSError {
        NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: errMsg])
    }
}

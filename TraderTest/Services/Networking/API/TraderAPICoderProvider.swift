//
//  TraderAPICoderProvider.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import Foundation

protocol DecoderProvider {
    static func decoder() -> JSONDecoder
}

protocol EncoderProvider {
    static func encoder() -> JSONEncoder
}

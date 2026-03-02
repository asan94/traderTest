//
//  Decodable+extension.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import Foundation

extension Decodable
{
    init<Key: Hashable>(_ dict: [Key: Any]) throws
    {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

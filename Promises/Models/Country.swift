//
//  Country.swift
//  Promises
//
//  Created by Anne Cahalan on 3/13/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import Foundation

struct Country: Codable {
    var name: String?
    var alpha2Code: String?
    var capital: String?
    var population: Int?
    var area: Double?
    var borders: [String]
    var currencies: [Currency]?
    var languages: [Language]?
}

struct Currency: Codable {
    var code: String?
    var name: String?
    var symbol: String?
}

struct Language: Codable {
    var name: String
}

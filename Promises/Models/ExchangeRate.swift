//
//  ExchangeRate.swift
//  Promises
//
//  Created by Anne Cahalan on 3/20/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import Foundation

struct ExchangeRate: Codable {
    var success: Bool
    var quotes: Quote
}

struct Quote: Codable {
    var conversion: String = ""
    var rate: Float = 0.0
}

extension Quote {
    
    struct QuoteKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: QuoteKeys.self)
        
        for key in container.allKeys {
            self.conversion = key.stringValue
            self.rate = try container.decode(Float.self, forKey: key)
        }
    }
}

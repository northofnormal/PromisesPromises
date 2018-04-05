//
//  Weather.swift
//  Promises
//
//  Created by Anne Cahalan on 3/27/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import Foundation

struct Weather: Codable {
    var conditions: [Conditions]
    var temp: Float
    
    enum WeatherCodingKeys: String, CodingKey {
        case conditions = "weather"
        case main
    }
}

struct Conditions: Codable {
    var description: String
    var iconCode: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case iconCode = "icon"
    }
    
}

extension Weather {
    enum MainWeatherCodingKeys: String, CodingKey {
        case temp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WeatherCodingKeys.self)
        self.conditions = try container.decode([Conditions].self, forKey: WeatherCodingKeys.conditions)
        
        let mainWeatherContainer = try container.nestedContainer(keyedBy: MainWeatherCodingKeys.self, forKey: Weather.WeatherCodingKeys.main)
        self.temp = try mainWeatherContainer.decode(Float.self, forKey: Weather.MainWeatherCodingKeys.temp)
    }
}



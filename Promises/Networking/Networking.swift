//
//  Networking.swift
//  Promises
//
//  Created by Anne Cahalan on 3/14/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import PromiseKit
import Foundation

class Networker {
    
    let allCountriesURLString = "https://restcountries.eu/rest/v2/all"
    let currencyConversionBaseURLString = "http://www.apilayer.net/api/live?access_key="
    let currencyAccessKey = "fe51ef2c8378bd6a06cbec562899a6ed"
    let weatherURLString = "http://api.openweathermap.org/data/2.5/weather?q="
    let weatherAccessKey = "27646e4699a300e1f3fe1773b6440e0b"
    let weatherIconURLString = "http://openweathermap.org/img/w/"
    
    // MARK: Promises Implementation

    func promiseFetchAllCountries() -> Promise<[Country]> {
        guard let url = URL(string: allCountriesURLString) else {
            fatalError("Could not format string -> all countries url")
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        return Promise { seal in
            let task = session.dataTask(with: urlRequest) { data, _, error in
                if let responseData = data {
                    let allCountries = self.decodeAllCountries(countryData: responseData)
                    seal.fulfill(allCountries)
                } else if let requestError = error {
                    seal.reject(requestError)
                }
            }
            
            task.resume()
        }
    }
    
    func promiseFetchCurrentExchangeRate(currencyCode: String) -> Promise<ExchangeRate> {
        guard let currencyURL = URL(string: currencyConversionBaseURLString + currencyAccessKey + "&currencies=\(currencyCode)&format=1") else {
            fatalError("Could not format string -> currency conversion url")
        }
        
        let urlRequest = URLRequest(url: currencyURL)
        let session = URLSession.shared
        
        return Promise { seal in
            let task = session.dataTask(with: urlRequest) { data, _, error in
                if let responseData = data {
                    guard let exchangeRate = self.decodeExchangeRateData(currencyData: responseData) else { return }
                    seal.fulfill(exchangeRate)
                } else if let requestError = error {
                    seal.reject(requestError)
                }
            }
            
            task.resume()
        }
    }
    
    func promiseFetchCapitalCityWeather(country: Country) -> Promise<Weather> {
        guard let capital = country.capital, let alpha2Code = country.alpha2Code else {
            fatalError("Could not unwrap capital city and alpha 2 code")
        }
        
        let capitalCity = capital.replacingOccurrences(of: " ", with: "%20")
        
        guard let weatherURL = URL(string: weatherURLString + capitalCity + "," + alpha2Code + "&units=imperial&APPID=" + weatherAccessKey) else {
            fatalError("Could not format string -> capital city weather url")
        }
        
        let urlRequest = URLRequest(url: weatherURL)
        let session = URLSession.shared
        
        return Promise { seal in
            let task = session.dataTask(with: urlRequest) { data, _, error in
                if let responseData = data {
                    guard let weather = self.decodeCapitalCityWeather(weatherData: responseData) else {
                        seal.reject(VariousErrors.weatherError)
                        return
                    }
                    seal.fulfill(weather)
                } else if let requestError = error {
                    seal.reject(requestError)
                }
            }
            
            task.resume()
        }
    }
    
    enum VariousErrors: Error {
        case weatherError
        case imageError
    }
    
    func promiseFetchWeatherIcon(iconCode: String) -> Promise<UIImage> {
        guard let iconURL = URL(string: weatherIconURLString + iconCode + ".png") else {
            fatalError("could not format string -> weather icon url")
        }
        
        return Promise { seal in
            if let imageData = try? Data(contentsOf: iconURL) {
                guard let iconImage = UIImage(data: imageData) else { return }
                seal.fulfill(iconImage)
            } else {
                seal.reject(VariousErrors.imageError)
            }
        }
    }
    
    // MARK: Vanilla implementation
    
    func fetchAllCountries(handler:  @escaping ([Country]?) -> ()) {
        guard let url = URL(string: allCountriesURLString) else { return }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard error == nil else {
                print("🗺 request error")
                return
            }
            
            guard let responseData = data else {
                print("🗺 data response error")
                return
            }
            
            let countryArray: [Country] = self.decodeAllCountries(countryData: responseData)
            handler(countryArray)
        })
        
        task.resume()
    }
    
    private func decodeAllCountries(countryData: Data) -> [Country] {
        var countryArray: [Country] = []
        
        let decoder = JSONDecoder()
        do {
            countryArray = try decoder.decode([Country].self, from: countryData)
            return countryArray
        } catch {
            print("🗺 error trying to convert json: \(error)")
            return countryArray
        }
    }
    
    func fetchCurrentExchangeRate(currencyCode: String, handler:  @escaping (ExchangeRate?) -> ()) {
        guard let currencyURL = URL(string: currencyConversionBaseURLString + currencyAccessKey + "&currencies=\(currencyCode)&format=1") else {
            print("💵 currency url error")
            return
        }
        
        let urlRequest = URLRequest(url: currencyURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                print("💵 request error: \(String(describing: error))")
                return
            }
            
            guard let responseData = data else {
                print("💵 data response error")
                return
            }
            
            guard let exchangeRate: ExchangeRate = self.decodeExchangeRateData(currencyData: responseData) else {
                print("💵 decoding error")
                return
            }
            handler(exchangeRate)
            
        })
        
        task.resume()
    }
    
    // MARK: Decode some models
    
    private func decodeExchangeRateData(currencyData: Data) -> ExchangeRate? {
        var exchangeRate: ExchangeRate
        
        let decoder = JSONDecoder()
        do {
            exchangeRate = try decoder.decode(ExchangeRate.self, from: currencyData)
            return exchangeRate
        } catch {
            print("💵 error trying to decode json: \(error)")
            return nil
        }
    }
    
    func fetchCapitalCityWeather(country: Country, handler:  @escaping (Weather?) -> ()) {
        guard let capital = country.capital, let alpha2Code = country.alpha2Code else {
            print("☔️ location error")
            return
        }
        
        let capitalCity = capital.replacingOccurrences(of: " ", with: "%20")
        
        guard let weatherURL = URL(string: weatherURLString + capitalCity + "," + alpha2Code + "&units=imperial&APPID=" + weatherAccessKey) else {
            print("☔️ weather url error")
            return
        }
        
        let urlRequest = URLRequest(url: weatherURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                print("☔️ request error: \(String(describing: error))")
                return
            }
            
            guard let responseData = data else {
                print("☔️ data response error")
                return
            }
            
            guard let capitalWeather = self.decodeCapitalCityWeather(weatherData: responseData) else {
                print("☔️ error trying to unwrap decoded weather")
                return
            }
            handler(capitalWeather)
        }
        
        task.resume()
    }
    
    private func decodeCapitalCityWeather(weatherData: Data) -> Weather? {
        var capitalWeather: Weather
        let decoder = JSONDecoder()
        do {
            capitalWeather = try decoder.decode(Weather.self, from: weatherData)
            return capitalWeather
        } catch {
            print("☔️ error trying to decode json: \(error)")
            return nil
        }
    }
    
    func fetchWeatherIcon(iconCode: String, handler:  @escaping (UIImage?) -> ()) {
        guard let iconURL = URL(string: weatherIconURLString + iconCode + ".png") else {
            print("🌈 weather icon url error")
            return
        }
        
        guard let imageData = try? Data(contentsOf: iconURL) else {
            print("🌈 error unwrapping image data")
            return
        }
        
        let iconImage = UIImage(data: imageData)
        handler(iconImage)
    }
    
}

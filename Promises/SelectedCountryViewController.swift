//
//  SelectedCountryViewController.swift
//  Promises
//
//  Created by Anne Cahalan on 3/15/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import PromiseKit
import UIKit

class SelectedCountryViewController: UIViewController {

    var selectedCountry: Country? = nil
    var exchangeRate: ExchangeRate? = nil
    var weather: Weather? = nil
    let networker = Networker()
    
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var capitalCityLabel: UILabel!
    @IBOutlet weak var languagesLabel: UILabel!
    @IBOutlet weak var currencyUnitLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var borderCountriesLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCountryUI()
        activityIndicator.startAnimating()
        
//        vanillaNetworkingGetTheStuff()
        promisesGetTheStuff()
    }
    
    private func promisesGetTheStuff() {
        guard let country = selectedCountry else {
            print("🗺 unable to locate a country")
            return
        }
        
        guard let currencyCode = country.currencies?.first?.code else {
            print("💵 unable to locate a currency for the selected coutry")
            return
        }

        when(fulfilled: networker.promiseFetchCurrentExchangeRate(currencyCode: currencyCode), networker.promiseFetchCapitalCityWeather(country: country))
        .then { exchangeRate, weather -> Promise<UIImage> in
            self.exchangeRate = exchangeRate
            self.weather = weather

            guard let iconCode = weather.conditions.first?.iconCode else {
                return Promise(error: NSError(domain: "app_domain", code: -1, userInfo: nil))
            }

            return self.networker.promiseFetchWeatherIcon(iconCode: iconCode)
        }
        .done { weatherImage in
            self.weatherIconImageView.image = weatherImage
        }.catch { error in
            print("🗺 some kind of error in getting the data for \(String(describing: country.name)) -> \(error)")
        }.finally {
            self.setupExchangeRateUI()
            self.setupWeatherUI()
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func vanillaNetworkingGetTheStuff() {
        activityIndicator.stopAnimating()
        
        guard let country = selectedCountry else {
            print("🗺 unable to locate a country")
            return
        }
        
        guard let currencyCode = country.currencies?.first?.code else {
            print("💵 unable to locate a currency for the selected coutry")
            return
        }
        
        networker.fetchCurrentExchangeRate(currencyCode: currencyCode) { rate in
            self.exchangeRate = rate
            DispatchQueue.main.async {
                self.setupExchangeRateUI()
            }
        }
        
        networker.fetchCapitalCityWeather(country: country) { weather in
            self.weather = weather
            DispatchQueue.main.async {
                self.setupWeatherUI()
            }
            
            guard let iconCode = self.weather?.conditions.first?.iconCode else {
                print("🌈 error unwrapping icon code")
                return
            }
            self.networker.fetchWeatherIcon(iconCode: iconCode) { weatherImage in
                DispatchQueue.main.async {
                    self.weatherIconImageView.image = weatherImage
                }
                
            }
        }
    }
    
    private func setUpCountryUI() {
        guard let country = selectedCountry else { return }
        countryNameLabel.text = country.name
        capitalCityLabel.text = country.capital
        
        setupBordersLabel(country)
        setupLanguagesLabel(country)
        setupCurrencyLabel(country)
    }
    
    private func setupWeatherUI() {
        guard let weather = weather else {
            setupWeatherErrorUI()
            return
        }
        
        weatherDescriptionLabel.text = weather.conditions.first?.description.capitalized
        currentTempLabel.text = "\(weather.temp)"
    }
    
    private func setupWeatherErrorUI() {
        weatherDescriptionLabel.text = "☔️ There was a problem getting the weather here."
        currentTempLabel.text = "?°"
    }
    
    private func setupExchangeRateUI() {
        guard let exchange = exchangeRate else { return }
        let symbol = selectedCountry?.currencies?.first?.symbol ?? ""
        let rate = exchange.quotes.rate
        
        exchangeRateLabel.text = "$1 US will get you \(symbol)\(rate)"
    }
    
    private func setupCurrencyLabel(_ country: Country) {
        currencyUnitLabel.text = country.currencies?.first?.name
    }
    
    private func setupLanguagesLabel(_ country: Country) {
        guard let languagesArray = country.languages else {
            languagesLabel.text = "No languages found. It must be very quiet here."
            return
        }
        
        let languages: [String] = languagesArray.compactMap { $0.name }
        languagesLabel.text = languages.joined(separator: ", ")
        
    }
    
    private func setupBordersLabel(_ country: Country) {
        guard !country.borders.isEmpty else {
            borderCountriesLabel.text = "No bordering countries."
            return
        }
        
        borderCountriesLabel.text = "\(country.borders)"
    }
    
    @IBAction func backButtonPressed() {
        dismiss(animated: true)
    }

}

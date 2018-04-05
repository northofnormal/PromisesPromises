//
//  CountryListTableViewCell.swift
//  Promises
//
//  Created by Anne Cahalan on 3/14/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import UIKit

class CountryListTableViewCell: UITableViewCell {

    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    
    public func setupCell(with country: Country) {
        countryNameLabel.text = country.name
        let formattedPopulation = formatPopulation(country.population ?? 0) 
        populationLabel.text = "population: \(formattedPopulation)"
    }
    
    private func formatPopulation(_ number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) else { return "Error formatting population number" }
        
        return formattedNumber
    }

}

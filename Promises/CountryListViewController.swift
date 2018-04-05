//
//  CountryListViewController.swift
//  Promises
//
//  Created by Anne Cahalan on 3/14/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import PromiseKit
import UIKit

class CountryListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var countryList: [Country] = []
    var selectedCountry: Country? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let networker = Networker()
        
        firstly {
            networker.promiseFetchAllCountries()
            }.done { countryArray in
                self.countryList = countryArray
                self.tableView.reloadData()
            }.catch { error in
                print("📝 some kind of error listing all countries -> \(error)")
        }

//        networker.fetchAllCountries { countries in
//            guard let list = countries else { return }
//            self.countryList = list
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let destination = segue.destination as? SelectedCountryViewController else { return }
        destination.selectedCountry = selectedCountry
    }

}

extension CountryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryListTableViewCell") as! CountryListTableViewCell
        let country = countryList[indexPath.row]
        cell.setupCell(with: country)
        
        return cell 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = countryList[indexPath.row]
        selectedCountry = country
        performSegue(withIdentifier: "SelectedCountrySegue", sender: self)
    }
    
}

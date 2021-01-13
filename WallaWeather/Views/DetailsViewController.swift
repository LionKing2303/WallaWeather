//
//  DetailsViewController.swift
//  WallaWeather
//
//  Created by Arie Peretz on 12/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import UIKit
import Combine

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static var segue: String {
        "detailsSegue"
    }
    
    // MARK: -- Variables
    var viewModel: DetailsViewModel?
    
    // MARK: -- Outlets
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: -- Private variables
    private var cityId: String?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 50.0
        tableView.register(UINib(nibName: FutureForecastTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FutureForecastTableViewCell.identifier)
        
        if let cityId = self.cityId {
            self.viewModel = DetailsViewModel(cityId: cityId, repository: ServiceDetailsRepository.init())
            self.bind()
        }
    }
    
    func set(cityId: String) {
        self.cityId = cityId
    }
 
    func bind() {
        guard let viewModel = self.viewModel else { return }
        
        // Bind a publisher that will tell us to refresh the collection view
        viewModel.refresh
            .sink { [weak self] in
               self?.refreshUI()
            }
            .store(in: &cancellables)
        
        viewModel.cityName
            .assign(to: \.text, on: cityName)
            .store(in: &cancellables)
        
        viewModel.currentTemperature
        .assign(to: \.text, on: currentTemperature)
        .store(in: &cancellables)
    }

    private func refreshUI() {
        tableView.reloadData()
    }
    
    // MARK: -- Table view delegate and data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataModel = self.viewModel?.dataModel else { return 0 }
        return dataModel.forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FutureForecastTableViewCell.identifier, for: indexPath) as? FutureForecastTableViewCell, let dataModel = self.viewModel?.dataModel else { return UITableViewCell() }
        cell.configure(
            date: dataModel.forecasts[indexPath.row].date,
            forecast: dataModel.forecasts[indexPath.row].temperature
        )
        return cell
    }
    

}

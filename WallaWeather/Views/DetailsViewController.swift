//
//  DetailsViewController.swift
//  WallaWeather
//
//  Created by Arie Peretz on 12/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import UIKit
import Combine

class DetailsViewController: UIViewController {

    static var segue: String {
        "detailsSegue"
    }
    
    var viewModel: DetailsViewModel?
    
    
    // MARK: -- Outlets
    @IBOutlet weak var cityName: UILabel!
    
    // MARK: -- Private variables
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bind()
    }
    
    func set(cityId: String) {
        self.viewModel = DetailsViewModel(cityId: cityId, repository: ServiceDetailsRepository.init())
    }
 
    func bind() {
        guard let viewModel = self.viewModel else { return }
        viewModel.cityName
            .assign(to: \.text, on: cityName)
            .store(in: &cancellables)
    }
    
}

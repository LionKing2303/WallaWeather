//
//  ViewController.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import UIKit
import Combine
import CoreLocation

// NOTE: Used to hold the layout switch button state and get the relevant asset
enum Layout: String {
    case list
    case grid
    
    func asset() -> String {
        switch self {
        case .list:
            return "rectangle.grid.1x2.fill"
        case .grid:
            return "square.grid.3x2.fill"
        }
    }
}

// NOTE: Used to get details about a city id or a specific location
struct UserLocation {
    enum LocationType {
        case id
        case location
    }
    
    let type: LocationType
    let cityId: String?
    let location: CLLocation?
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    // MARK: -- Outlets
    @IBOutlet weak var lastUpdate: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layoutSwitch: UIButton!
    
    // MARK: -- Private variables
    private var viewModel: MainViewModel = .init(repository: ServiceMainRepository.init())
    private lazy var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.delegate = self
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    private var currentLocation: CLLocation?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        bind()
        viewModel.fetchForecasts()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func registerCells() {
        // Register cells
        collectionView.register(UINib(nibName: LargeCityForecastCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: LargeCityForecastCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: CompactCityForecastCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CompactCityForecastCollectionViewCell.identifier)
    }
    
    private func bind() {
        // Bind a publisher that will tell us to refresh the collection view
         viewModel.refresh
             .sink { [weak self] in
                self?.refreshUI()
             }
             .store(in: &cancellables)
        
        // Bind a string publisher that will tell us what asset to use on the layout switch button
        viewModel.layoutAsset
            .replaceNil(with: "")
            .sink { [weak self] asset in
                self?.layoutSwitch.setImage(UIImage(systemName: asset), for: .normal)
            }
            .store(in: &cancellables)
        
        // Bind a string publisher that will show us the last update date
        viewModel.lastUpdate
            .assign(to: \.text, on: lastUpdate)
            .store(in: &cancellables)
    }

    private func refreshUI() {
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    @IBAction func onLayoutSwitch(_ sender: Any) {        
        viewModel.toggleLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataModel.forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: ForecastCollectionViewCell?

        if viewModel.getLayout() == .grid {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: LargeCityForecastCollectionViewCell.identifier, for: indexPath) as? LargeCityForecastCollectionViewCell
        } else if viewModel.getLayout() == .list {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompactCityForecastCollectionViewCell.identifier, for: indexPath) as? CompactCityForecastCollectionViewCell
        }
    
        cell?.configure(
            cityId: viewModel.dataModel.forecasts[indexPath.item].cityId,
            forecast: viewModel.dataModel.forecasts[indexPath.item]
        )
        
        return cell ?? UICollectionViewCell()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // Set collection view cell custom size for each layout
        if viewModel.getLayout() == .grid {
            return CGSize(width: UIScreen.main.bounds.width, height: 60.0)
        } else if viewModel.getLayout() == .list {
            return CGSize(width: (UIScreen.main.bounds.width-30)/3, height: 150.0)
        }
        return .zero
    }
}

extension MainViewController {
    // Handle the segue to the city screen (details screen)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: DetailsViewController.segue, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath, let cell = self.collectionView.cellForItem(at: indexPath) as? ForecastCollectionViewCell {
            if let detailsViewController = segue.destination as? DetailsViewController, let cityId = cell.getCityId() {
                if cityId.isEmpty {
                    detailsViewController.set(location: UserLocation(type: .location, cityId: nil, location: currentLocation))
                } else {
                    detailsViewController.set(location: UserLocation(type: .id, cityId: cityId, location: nil))
                }
            }
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
        manager.stopUpdatingLocation()
    }
}

//
//  ViewController.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import UIKit
import Combine

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

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    // MARK: -- Outlets
    @IBOutlet weak var lastUpdate: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layoutSwitch: UIButton!
    
    // MARK: -- Private variables
    private var viewModel: MainViewModel = .init(repository: MainRepository.init())
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        bind()
        viewModel.fetchForecasts()
    }
    
    private func registerCells() {
        // Register cells
        collectionView.register(UINib(nibName: LargeCityForecastCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: LargeCityForecastCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: CompactCityForecastCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CompactCityForecastCollectionViewCell.identifier)
    }
    
    private func bind() {
        // Bind a publisher that will tell us to refresh the collection view
         viewModel.refresh
             .sink { _ in
                self.refreshUI()
             }
             .store(in: &cancellables)
        
        // Bind a string publisher that will tell us what asset to use on the layout switch button
        viewModel.layoutAsset
            .replaceNil(with: "")
            .sink { (asset) in
                self.layoutSwitch.setImage(UIImage(systemName: asset), for: .normal)
            }
            .store(in: &cancellables)
        
        // Bind a string publisher that will show us the last update date
        viewModel.lastUpdate
            .assign(to: \.text, on: lastUpdate)
            .store(in: &cancellables)
    }

    private func refreshUI() {
        collectionView.reloadData()
    }
    
    @IBAction func onLayoutSwitch(_ sender: Any) {        
        viewModel.toggleLayout()
        refreshUI()
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
    
        cell?.set(forecast: viewModel.dataModel.forecasts[indexPath.item])
        return cell ?? UICollectionViewCell()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // Set collection view cell custom size for each layout
        if viewModel.getLayout() == .grid {
            return CGSize(width: UIScreen.main.bounds.width, height: 44.0)
        } else if viewModel.getLayout() == .list {
            return CGSize(width: (UIScreen.main.bounds.width-30)/3, height: 92.0)
        }
        return .zero
    }
}

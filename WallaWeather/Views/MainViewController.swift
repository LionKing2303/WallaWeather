//
//  ViewController.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import UIKit
import Combine

enum Layout {
    case list
    case grid
    
    func asset() -> String {
        switch self {
        case .grid:
            return "rectangle.grid.1x2.fill"
        case .list:
            return "square.grid.3x2.fill"
        }
    }
}

struct Some: Codable {
    
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    // MARK: -- Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layoutSwitch: UIButton!
    
    // MARK: -- Private variables
    private var viewModel: MainViewModel = .init(repository: MainRepository.init())
    private var cancellables: Set<AnyCancellable> = []
    private var layout: Layout = .list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.register(UINib(nibName: LargeCityForecastCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: LargeCityForecastCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: CompactCityForecastCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CompactCityForecastCollectionViewCell.identifier)

        viewModel.refresh
            .sink { _ in
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
       
    }

    @IBAction func onLayoutSwitch(_ sender: Any) {
        if layout == .list { layout = .grid }
        else if layout == .grid { layout = .list }
        collectionView.reloadData()
        layoutSwitch.setImage(UIImage(systemName: layout.asset()), for: .normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataModel.forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: ForecastCollectionViewCell?
        
        if self.layout == .list {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: LargeCityForecastCollectionViewCell.identifier, for: indexPath) as? LargeCityForecastCollectionViewCell
        } else if self.layout == .grid {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompactCityForecastCollectionViewCell.identifier, for: indexPath) as? CompactCityForecastCollectionViewCell
        }
    
        cell?.set(forecast: viewModel.dataModel.forecasts[indexPath.item])
        return cell ?? UICollectionViewCell()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if self.layout == .list {
            return CGSize(width: UIScreen.main.bounds.width, height: 44.0)
        } else if self.layout == .grid {
            return CGSize(width: (UIScreen.main.bounds.width-30)/3, height: 92.0)
        }
        return .zero
    }
}

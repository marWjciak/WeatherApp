//
//  FiveDaysWeather.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 28/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import Foundation
import UIKit

class FiveDaysWeatherController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var forecasts: WeatherModel?
    
    @IBOutlet weak var weatherTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherTableView.estimatedRowHeight = 80.0
        weatherTableView.dataSource = self
        weatherTableView.delegate = self
        weatherTableView.register(UINib(nibName: K.WeatherCell.nibName, bundle: nil), forCellReuseIdentifier: K.WeatherCell.identifier)
        
        navigationItem.title = forecasts?.cityName
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let forecastCount = forecasts?.dayForecasts.count {
            return forecastCount
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: K.WeatherCell.identifier, for: indexPath) as! WeatherCell
        cell.configureFor(forecasts?.dayForecasts[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if  UIDevice.current.orientation.isLandscape {
            return tableView.bounds.size.height / 4
        }
        
        return tableView.bounds.size.height / 8
    }
    
}

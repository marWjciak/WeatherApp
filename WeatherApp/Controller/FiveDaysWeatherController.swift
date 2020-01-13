//
//  FiveDaysWeather.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 28/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import Foundation
import UIKit

class FiveDaysWeatherController: UIViewController {
    var forecasts: WeatherModel?
    
    @IBOutlet weak var weatherTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherTableView.dataSource = self
        weatherTableView.register(UINib(nibName: "WeatherCell", bundle: nil), forCellReuseIdentifier: "WeatherReusableCell")
        
    }
    
}

extension FiveDaysWeatherController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let forecastCount = forecasts?.dayForecast.count {
            return forecastCount
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let forecastData = forecasts?.dayForecast[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherReusableCell", for: indexPath) as! WeatherCell
        
        DispatchQueue.main.async {
            cell.weatherDate.text = forecastData?.date
            cell.weatherIcon.image = UIImage(systemName: forecastData?.icon ?? "")
            cell.weatherTemp.text = String(forecastData?.temp ?? 0)
            cell.weatherDescription.text = forecastData?.description ?? ""
        }
        
        return cell
    }
}
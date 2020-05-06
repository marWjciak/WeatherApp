//
//  WeatherCell.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 28/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    @IBOutlet var weatherIcon: UIImageView!
    @IBOutlet var weatherDescription: UILabel!
    @IBOutlet var weatherTemp: UILabel!
    @IBOutlet var weatherDate: UILabel!
    @IBOutlet var weatherTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureFor(_ weatherData: DayForecast?) {
        if let safeWeatherData = weatherData {
            weatherIcon.image = UIImage(systemName: safeWeatherData.icon)
            weatherTemp.text = String(safeWeatherData.temp)
            weatherDescription.text = safeWeatherData.description
            weatherDate.text = safeWeatherData.formattedDate
            weatherTime.text = safeWeatherData.formattedTime
        }
    }
}

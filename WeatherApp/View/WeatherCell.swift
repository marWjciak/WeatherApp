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

    func configureFor(_ weatherData: DayForecast!) {
        weatherIcon.image = UIImage(systemName: weatherData?.icon ?? "")
        weatherTemp.text = String(weatherData?.temp ?? 0)
        weatherDescription.text = weatherData?.description ?? ""
        weatherDate.text = weatherData?.formattedDate
        weatherTime.text = weatherData?.formattedTime
    }
}

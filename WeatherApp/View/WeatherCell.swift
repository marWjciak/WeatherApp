//
//  WeatherCell.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 28/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherDate: UILabel!
    @IBOutlet weak var weatherTime: UILabel!
    
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

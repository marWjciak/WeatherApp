//
//  LocationWeatherswift
//  WeatherApp
//
//  Created by Marcin Wójciak on 17/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import SwipeCellKit
import UIKit

class LocationWeatherCell: SwipeTableViewCell {
    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var currentTemp: UILabel!
    @IBOutlet var cityName: UILabel!
    @IBOutlet var weatherDescription: UILabel!
    @IBOutlet var isFromLocationImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureFor(_ weatherdata: WeatherModel!, andDelegate delegate: SwipeTableViewCellDelegate) {
        self.delegate = delegate

        if !weatherdata.dayForecasts.isEmpty {
            weatherImage.image = UIImage(systemName: weatherdata.dayForecasts[0].icon)
            currentTemp.text = String(weatherdata.dayForecasts[0].temp)
            cityName.text = weatherdata.cityName
            weatherDescription.text = weatherdata.dayForecasts[0].description
            isFromLocationImage.isHidden = !weatherdata.fromLocation
        }
    }
}

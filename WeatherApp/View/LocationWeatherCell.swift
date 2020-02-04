//
//  LocationWeatherswift
//  WeatherApp
//
//  Created by Marcin Wójciak on 17/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit
import SwipeCellKit

class LocationWeatherCell: SwipeTableViewCell {

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var isFromLocationImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureFor(_ weatherdata: WeatherModel!, andDelegate delegate: SwipeTableViewCellDelegate){

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

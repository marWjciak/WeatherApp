//
//  LocationWeatherCell.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 17/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit

class LocationWeatherCell: UITableViewCell {

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var isFromLocationImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

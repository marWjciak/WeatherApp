//
//  Spinner.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 02/03/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import UIKit

class LoadingIndicator {
    static var spinner: UIActivityIndicatorView?
    static var style: UIActivityIndicatorView.Style = .large
    static var backgroundColor = UIColor(named: K.Assets.upperColor)?.withAlphaComponent(0.4)
    static var color = UIColor { (traitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
        }
    }
    static var isRunning: Bool {
        return spinner != nil
    }

    static func start(onView: UIView,
                      style: UIActivityIndicatorView.Style = style,
                      backgroundColor: UIColor = backgroundColor!,
                      color: UIColor = color) {
        guard spinner == nil else { return }

        spinner = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        spinner?.style = style
        spinner?.hidesWhenStopped = true
        spinner?.backgroundColor = backgroundColor
        spinner?.color = color
        onView.addSubview(spinner!)
        spinner?.startAnimating()

    }

    static func stop() {
        guard spinner != nil else { return }

        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
        spinner = nil
    }
}

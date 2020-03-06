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
    fileprivate static var spinner: UIActivityIndicatorView?
    fileprivate static var style: UIActivityIndicatorView.Style = .large
    fileprivate static var backgroundColor = UIColor(named: K.Assets.upperColor)?.withAlphaComponent(0.4)
    fileprivate static var color = K.color

    fileprivate static var tempView: UIView?

    static var isRunning: Bool {
        return spinner != nil
    }

    static func start(on view: UIView,
                      style: UIActivityIndicatorView.Style = style,
                      backgroundColor: UIColor = backgroundColor!,
                      color: UIColor = color) {
        guard spinner == nil else { return }

        spinner = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        spinner?.style = style
        spinner?.hidesWhenStopped = true
        spinner?.backgroundColor = backgroundColor
        spinner?.color = color
        view.addSubview(spinner!)
        tempView = view
        spinner?.startAnimating()
    }

    static func stop() {
        guard spinner != nil else { return }

        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
        spinner = nil
        tempView = nil
    }

    static func update() {
        guard spinner != nil else { return }

        if let view = tempView {
            stop()
            start(on: view)
        }
    }
}

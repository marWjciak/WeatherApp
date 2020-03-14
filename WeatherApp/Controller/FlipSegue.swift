//
//  FlipSegueTransition.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 14/03/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit

class FlipSegue: UIStoryboardSegue {

    override func perform() {
        flip()
    }

    func flip() {
        let toViewController = self.destination
        let fromViewController = self.source

        let containerView = fromViewController.view.superview
        let originalCenter = fromViewController.view.center

        toViewController.view.center = originalCenter

        containerView?.addSubview(toViewController.view)

        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]

        UIView.transition(with: fromViewController.view, duration: 1.0, options: transitionOptions, animations: {
            fromViewController.view.isHidden = true
        })

        UIView.transition(with: toViewController.view, duration: 1.0, options: transitionOptions, animations: {
            toViewController.view.isHidden = false
        })
    }
}

//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 24/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import IQKeyboardManagerSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        WeatherData.shared.weatherManager = WeatherManager()

        return true
    }

    //MARK: - Set Application Supported Interface Orientations

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.allButUpsideDown]
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // save data here!
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // pass info on forground to top most view controller or all of them
        /*
         delegate
         notification center

         **/

        // NotificationCenter.default.post(name: NSNotification.Name, object: <#T##Any?#>)
    }
}

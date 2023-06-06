//
//  AppDelegate.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/1.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let window = UIWindow()

        let manager = FontManager()
        let fontSelectorViewModel = FontSelectorViewModel(manager: manager)
        window.rootViewController = ViewController(fontSelectorViewModel: fontSelectorViewModel)
        window.makeKeyAndVisible()

        self.window = window

        return true
    }

}


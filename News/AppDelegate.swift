//
//  AppDelegate.swift
//  News
//
//  Created by Nikita Teplyakov on 15.05.2020.
//  Copyright © 2020 Nikita Teplyakov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	private let dependencyContainer = DependencyContainer()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = dependencyContainer.makeTabBarBuilder().buildModule()
		window?.makeKeyAndVisible()

		setupHTTPCache()

		return true
	}

	func setupHTTPCache() {
		URLCache.shared = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
	}
}


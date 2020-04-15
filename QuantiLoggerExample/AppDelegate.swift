//
//  AppDelegate.swift
//  TableViewDatasourceTest
//
//  Created by Martin Troup on 09.11.16.
//  Copyright © 2016 quanti. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Loggers setup
        let logManager = LogManager.shared

		logManager.setApplicationCallbackLogger(onLevel: .warn)

        let consoleLogger = ConsoleLogger()
        consoleLogger.levels = [.warn, .debug]
        _ = logManager.add(consoleLogger)

        let fileLogger = FileLogger()
        fileLogger.levels = [.error, .warn]
        _ = logManager.add(fileLogger)
        
        QLog("test", onLevel: .warn)
        QLog("test2\ntest2test2\ntest2test2test2\ntest2\ntest2test2\ntest2test2test2\n", onLevel: .warn)


        // Draw controller
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.rootViewController = MainTabBarController()
            window.makeKeyAndVisible()
        }

		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			logManager.setApplicationCallbackLogger(with: [.didChangeStatusBarOrientation], onLevel: .debug)
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
			logManager.setApplicationCallbackLogger(with: [.willChangeStatusBarFrame, .willChangeStatusBarOrientation], onLevel: .warn)
		}

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


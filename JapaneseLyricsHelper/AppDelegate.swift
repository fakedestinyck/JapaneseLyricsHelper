//
//  AppDelegate.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/23/2017.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    @objc func updateMethod(_ response: [AnyHashable: Any]) {
        if (response["downloadURL"] != nil) {
            print(response)
            let message = response["releaseNote"] as? String
            let alert = UIAlertController(title: "有新的版本辣！", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "去更新", style: .default, handler: { (action) in
                //self.createScore()
//                if dismissOrNot == true {
//                    self.dismiss(animated: true, completion: nil)
//                }
            }))
//            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in}))
            SwiftSpinner.hide()
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        SwiftSpinner.hide()
        //    调用checkUpdateWithDelegete后可用此方法来更新本地的版本号，如果有更新的话，在调用了此方法后再次调用将不提示更新信息。
//        PgyUpdateManager.sharedPgy().updateLocalBuildNumber()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        PgyUpdateManager.sharedPgy().start(withAppId: "f1e93f559616b8d87ae17cbbd6a37a9e");
        SwiftSpinner.useContainerView(self.window?.rootViewController?.view)
        SwiftSpinner.show("检查更新中...")
        PgyUpdateManager.sharedPgy().checkUpdate(withDelegete: self, selector: #selector(self.updateMethod))
//        PgyUpdateManager.sharedPgy().checkUpdate()
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


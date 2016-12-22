//
//  AppDelegate.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit
import AWSS3
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Breadcrumb")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.usEast1,
            identityPoolId: "us-east-1:16f753ac-4d74-42c0-a10b-1fbd18692eb1")

        let configuration = AWSServiceConfiguration(region: AWSRegionType.usWest1,
            credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch {
        }
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            print("SIMULATOR")
            Global.setDevice(Data(bytes: UnsafePointer<UInt8>([0xff] as [UInt8]), count: 1))
        #else
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            application.registerForRemoteNotifications()
        #endif
        
//        if launchOptions != nil {
//            let url = launchOptions![UIApplicationLaunchOptionsURLKey] as? NSURL
//            if url != nil {
//                Utils.delay(3) {
//                    self.application(application, openURL: url!, options: [:])
//                }
//            }
//        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        Global.setDevice(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error getting token \(error)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        print("Handle identifier : \(identifier)")
        // Must be called when finished
        completionHandler()
    }

    func application(_ application: UIApplication, didReceive notificaiton: UILocalNotification){
        print("Handle identifier")
        // Notificaiton has fired.  Insert your code here
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        Utils.delay(2) {
            print("Launching app from url \(url)")
            let navigationController = self.window?.rootViewController as! UINavigationController
            let mapController = navigationController.topViewController as? MapController
            mapController!.handleOpenURL(url)
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let navigationController = window?.rootViewController as! UINavigationController
        navigationController.topViewController?.viewWillAppear(false)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


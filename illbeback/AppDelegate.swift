//
//  AppDelegate.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let credentialsProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
            AWSRegionType.USEast1,
            identityPoolId: "us-east-1:16f753ac-4d74-42c0-a10b-1fbd18692eb1")

        let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest1,
            credentialsProvider:credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(configuration)

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch {
        }
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            print("SIMULATOR")
            Global.setDevice(NSData(bytes: [0xff] as [UInt8], length: 1))
        #else
            let settings = UIUserNotificationSettings(forTypes: [.Badge, .Alert], categories: nil)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        #endif
        
        if launchOptions != nil {
            let url = launchOptions![UIApplicationLaunchOptionsURLKey] as? NSURL
            if url != nil {
                self.application(application, openURL: url!, options: [:])
            }
        }
        
        return true
    }
    
    // implemented in your application delegate
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Got token data! \(deviceToken)")
        Global.setDevice(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Couldn't register: \(error)")
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        print("Handle identifier : \(identifier)")
        // Must be called when finished
        completionHandler()
    }

    func application(application: UIApplication, didReceiveLocalNotification notificaiton: UILocalNotification){
        print("Handle identifier")
        // Notificaiton has fired.  Insert your code here
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
            print("Launching app from url \(url)")
            let navigationController = window?.rootViewController as! UINavigationController
            let mapController = navigationController.topViewController as? MapController
            mapController!.handleOpenURL(url)
          return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let navigationController = window?.rootViewController as! UINavigationController
        navigationController.topViewController?.viewWillAppear(false)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


//
//  AppDelegate.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 5/1/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//
/*
 Heart Icon: https://www.iconfinder.com/icons/1118211/disease_graph_heart_medical_medicine_icon#size=512
 
 
 */

import UIKit
import SMARTMarkers
import ResearchKit
import SMART
import UserNotifications
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var fhir: FHIRManager! = {
        return FHIRManager.SMARTSandbox()
    }()
    
    var omron: OMRON!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        if fhir.main.awaitingAuthCallback {
            return fhir.main.didRedirect(to: url)
        }
        
        if url.scheme == "smpro" {
            
            fhir.callbackManager?.handleRedirect(url: url)
            
            
            
        }
        

        return false
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        

        
    }
    
    func showOmron() {
        

        omron.sm_taskController { (task, e) in
            if let t = task {
                self.window?.rootViewController?.present(t, animated: true, completion: nil)
            }
        }
        
        
    }
    

    
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
    
}

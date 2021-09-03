//
//  AppDelegate.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/11/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWCore
import PWEngagement
import CedarsSinai

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        configurePWCore()
        
        return true
    }
    
    func configurePWCore() {
        if let configurationDitionary = CSPlistReader.dictionary(plistName: "Config", inBundle: Bundle.main),
            let appID = configurationDitionary["appID"] as? String,
            let accessKey = configurationDitionary["accessKey"] as? String,
            let signatureKey = configurationDitionary["signatureKey"] as? String {
                PWCore.setApplicationID(appID, accessKey: accessKey, signatureKey: signatureKey)
                PWEngagement.start(withMaasAppId: appID, accessKey: accessKey, signatureKey: signatureKey) { (error) in
                    if let error = error {
                        print("Error starting Engagement: \(error.localizedDescription)")
                    }
                }
        }
    }
}

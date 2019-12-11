//
//  App+Config.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 03/05/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import Foundation
import SMARTMarkers
import SMART

/*
 - Settings for FHIR Server
 - Config.xcconfig has all the config settings for a sample FHIR Server
 - Configuration settings file format documentation can be found at:
 - https://help.apple.com/xcode/#/dev745c5c974
 
 ******
 Replace URLs with your own settings for a FHIR server
 ******
 */

extension FHIRManager {
    
    /**
     SMART Sandbox Credentials take from Config.xcconfig via App's
     - REPLACE Settings or create a new Client for other FHIR Servers
     */
    class func SMARTSandbox() -> FHIRManager {
        
        let infoDict = Bundle.main.infoDictionary!
        guard var baseURI = infoDict["FHIR_BASE_URL"] as? String else {
            fatalError("Need FHIR Endpoint")
        }
        if !baseURI.hasPrefix("http") {
            baseURI = "https://" + baseURI
        }
        
        let settings = [
            "client_name"   : "easipro-clinic",
            "client_id"     : "51914e53-5230-4e35-964a-c62139884120",
            "redirect"      : "smartmarkers-home://smartcallback",
            "scope"         : "openid profile user/*.* launch"
        ]
        let smart_baseURL = URL(string: baseURI)!
        let client = Client(baseURL: smart_baseURL, settings: settings)
        client.authProperties.granularity = .tokenOnly
        return FHIRManager(main: client, promis: PROMISClient.New())
        
    }
    
    /**
     OMRON Credentials taken from Config.xcconfig via App's Info.plist
     - REPLACE Settings with your own
     */
    class func OmronAuthSettings() -> [String: Any]? {
        
        let infoDict = Bundle.main.infoDictionary!
        guard let clientid = infoDict["OMRON_ClientId"] as? String, let secret = infoDict["OMRON_Secret"] as? String else {
            return nil
        }
        
        let settings = [
            "client_id": clientid,
            "client_secret": secret,
            "scope": "bloodpressure activity openid offline_access",
            "redirect_uris": ["smpro://"],
            "authorize_uri": "https://ohi-oauth.numerasocial.com/connect/authorize",
            "token_uri": "https://ohi-oauth.numerasocial.com/connect/token",
            "keychain" : true
            ] as [String : Any]
        return settings
    }
}




/**
 AssessmentCenter's Credentials taken from Config.xcconfig via App's Info.plist
 - REPLACE Credentials with your own
 */
extension PROMISClient {
    
    public class func New() -> PROMISClient {
        
        let infoDict = Bundle.main.infoDictionary!
        guard var baseURI = infoDict["ASSESSMENTCENTER_BASE_URL"] as? String else {
            fatalError("Need PROMIS AssessmentCenter Endpoint")
        }
        
        if !baseURI.hasPrefix("http") {
            baseURI = "https://" + baseURI
        }
        
        return PROMISClient(baseURL: URL(string: baseURI)!,
                            client_id: infoDict["ASSESSMENTCENTER_ACCESSID"] as! String,
                            client_secret: infoDict["ASSESSMENTCENTER_ACCESSTOKEN"] as! String)
    }
}

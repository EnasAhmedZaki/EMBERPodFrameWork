//
//  EnvironmentConfiguration.swift
//  OsirisBio Provider
//
//  Created by Enas A. Zaki on 4/15/19.
//  Copyright © 2019 EMBER Medical. All rights reserved.
//

import Foundation

enum EnvType: String {
    case QA
    case UAT
    case Prod
    case Mock
    
    func getReadableValue() -> String {
        switch self {
        case .QA:
            return "Dev"
        case .UAT:
            return "Staging"
        case .Prod:
            return "Production"
        case .Mock:
            return "Mock"
        }
    }
}

let kFABMFPEnvironmentURLPlist  = "Environment"

public class EnvironmentConfiguration {

    var kEnvironment = "UAT"
    var ServerURL: String = ""
    var LabsServerURL: String = ""
    var APIVersion: String = ""
    var LabAPIVersion: String = ""
    var environment = EnvType.UAT
    var GoogleBrowserAPIKey: String = ""
    var GoogleClientID: String = ""
    var GoogleMapAPIKey: String = ""
    var OpenTokAPIKey: String = ""
    var StripeKey: String = ""
    var FirebaseDBName: String = ""
    var FBAppID: String = ""
    var NotificationSubtitle: String = ""
    var SendBirdAPIKey: String = ""
    var SendBirdAppID: String = ""
    var SendBirdAPIToken: String = ""
    var byPassVerificationCode: Bool = false
    var IntercomAPIKey: String = ""
    var IntercomAppID: String = ""
    var EnableIPStack: Bool = false
    var IPStackAccesskey: String = ""
    
    class var sharedInstance: EnvironmentConfiguration {

        struct Static {
            static let instance: EnvironmentConfiguration = EnvironmentConfiguration()

        }
        return Static.instance
    }

    init() {

        kEnvironment = readFromPlistWithKey(kFABMFPEnvironmentURLPlist, moduleKey: "Environment Configuration", valueAtKey: "Environment")

        switch kEnvironment {
        case "Prod":
            loadEnvironmentWithType(envType: .Prod)
        case "QA":
            loadEnvironmentWithType(envType: .QA)
        case "UAT":
            loadEnvironmentWithType(envType: .UAT)
        case "Mock":
            loadEnvironmentWithType(envType: .Mock)
        default:
            loadEnvironmentWithType(envType: .QA)
        }
    }

    func loadEnvironmentWithType(envType: EnvType) {

        environment = envType
        let environmentDetail: Array = readArrayFromPlistWithKey(kFABMFPEnvironmentURLPlist, moduleKey: "Environment Configuration", valueAtKey: "EnvironmentList")

        var type = "QA"
        switch envType {

        case .Prod:
            type = "Prod"
        case .QA:
            type = "QA"
        case .UAT:
            type = "UAT"
        case .Mock:
            type = "Mock"
        }

        for environmentItem in environmentDetail {
            let environmentDict: NSDictionary =  environmentItem as! NSDictionary
            let Environment = environmentDict.value(forKey: "Environment") as? String ?? ""

            if Environment == type {
                ServerURL = environmentDict.value(forKey: "ServerURL")  as? String  ?? ""
                LabsServerURL = environmentDict.value(forKey: "LabsServerURL")  as? String  ?? ""
                APIVersion = environmentDict.value(forKey: "APIVersion")  as? String  ?? ""
                LabAPIVersion = environmentDict.value(forKey: "LabAPIVersion")  as? String  ?? ""
                GoogleBrowserAPIKey = environmentDict.value(forKey: "GoogleBrowserAPIKey") as? String ?? ""
                GoogleClientID = environmentDict.value(forKey: "GoogleClientID") as? String ?? ""
                GoogleMapAPIKey = environmentDict.value(forKey: "GoogleMapAPIKey") as? String ?? ""
                OpenTokAPIKey = environmentDict.value(forKey: "OpenTokAPIKey") as? String ?? ""
                StripeKey = environmentDict.value(forKey: "StripeKey") as? String ?? ""
                FirebaseDBName = environmentDict.value(forKey: "FirebaseDBName") as? String ?? ""
                FBAppID = environmentDict.value(forKey: "FBAppID") as? String ?? ""
                NotificationSubtitle = environmentDict.value(forKey: "NotificationSubtitle") as? String ?? ""
                SendBirdAPIKey = environmentDict.value(forKey: "SendBirdAPIKey") as? String ?? ""
                SendBirdAppID = environmentDict.value(forKey: "SendBirdAppID") as? String ?? ""
                SendBirdAPIToken = environmentDict.value(forKey: "SendBirdAPIToken") as? String ?? ""
                byPassVerificationCode = environmentDict.value(forKey: "byPassVerificationCode") as? Bool ?? false
                IntercomAPIKey = environmentDict.value(forKey: "IntercomAPIKey") as? String ?? ""
                IntercomAppID = environmentDict.value(forKey: "IntercomAppID") as? String ?? ""
                EnableIPStack = environmentDict.value(forKey: "EnableIPStack") as? Bool ?? false
                IPStackAccesskey = environmentDict.value(forKey: "IPStackAccesskey") as? String ?? ""
            }
        }
    }

}

extension EnvironmentConfiguration {

    func readFromPlistWithKey (_ plist: String, moduleKey paramKey: String, valueAtKey paramValueAtKeyKey: String) -> String {

        var plistValueAtKey: String = ""
        let bundleName = Bundle.init(identifier: "TestResourceBundle")
        if let path = bundleName?.path(forResource: plist, ofType: "plist") {
            let plistDict = NSDictionary(contentsOfFile: path)
            if let plistModuleDict = (plistDict?.object(forKey: paramKey)) as? NSDictionary {
                plistValueAtKey = plistModuleDict.value(forKey: paramValueAtKeyKey) as? String ?? ""
            }
        }

        return plistValueAtKey
    }

    func readArrayFromPlistWithKey (_ plist: String, moduleKey paramKey: String, valueAtKey paramValueAtKeyKey: String) -> [AnyObject] {

        var plistValueAtKey: [AnyObject] = []
        
        let bundleName = Bundle.init(identifier: "TestResourceBundle")
        if let path = bundleName?.path(forResource: plist, ofType: "plist") {
            let plistDict = NSDictionary(contentsOfFile: path)
            if let plistModuleDict = (plistDict?.object(forKey: paramKey)) as? NSDictionary {
                plistValueAtKey = plistModuleDict.value(forKey: paramValueAtKeyKey) as? [AnyObject] ?? []
            }
        }

        return plistValueAtKey
    }

}

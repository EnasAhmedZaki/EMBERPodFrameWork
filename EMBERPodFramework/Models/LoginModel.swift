//
//  LoginModel.swift
//  OsirisBioUser
//
//  Created by Pramod More on 7/25/18.
//  Copyright © 2018 Biz4Solutions. All rights reserved.
//

import Foundation
import RxAlamofire
import ObjectMapper

public class BaseModel: Mappable {

    var code: Int = 0
    var message = ""
    var status = ""
    var timestamp: Int64?
    init() {

    }
    required public init?(map: Map) {

    }

    public func mapping(map: Map) {
        code <- map["code"]
        message <- map["message"]
        status <- map["status"]
        timestamp <- map["timestamp"]
    }
}


public class LoginModel: BaseModel {

    var data: LoginData?
    required init?(map: Map) {
        super.init(map: map)
    }

    public override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }

}

class LoginData: Mappable {

    var userId: String?
    var fullName: String = ""
    var authToken: String?
    var refreshToken: String?
    var email: String = ""
    var countryDialCode: String? = ""
    var credit: Double = 0.0
    var creditCurrency: String? = ""
    var phoneNo: String? = ""
    var gender = ""
    var dob: Int64 = 0
    var isUserSubscribed: Bool?
    var address: String?
    var dobStr = ""
    var insuranceDateStr = ""
    var profileUrl: String?
    var profileImageURL: URL?
//    var roleName: AppRoleTypeConstants?
//    var signupType: AppLoginTypeConstants?
    var countryNameISO: String?
    var stateNameISO: String?
    var sendBirdId: String = ""
    var isEmailVerified: Bool?
    var insuranceName: String?
    var insuranceID: String?
    var insuranceNumber: String?
    var insuranceDate: Double?
    var isPhoneVerified: Bool?
//    var signStatus: SignUpState?
//
//    var chronicMedications: [ChronicMedicationDetailsModel]?
//    var chronicDiseases: [ChronicDiseaseDetailsModel]?
//    var userRating: Double?
//    var signUpState: SignUpState?
    
    required init(map: Map) {

    }

     func mapping(map: Map) {

        print(map.JSON)
        userId <- map["userId"]
        fullName <- map["fullName"]
        authToken <- map["authToken"]
        refreshToken <- map["refreshToken"]
        email <- map["email"]
        countryDialCode <- map["dialingCode"]
        phoneNo <- map["phoneNumber"]
        dob <- map["dob"]
        address <- map["address"]
        profileUrl <- map["profileUrl"]
        isUserSubscribed <- map["isUserSubscribed"]
        countryNameISO <- map["countryNameISO"]
        credit <- map["credit"]
        creditCurrency <- map["creditCurrency"]
        stateNameISO <- map["stateNameISO"]
        isEmailVerified <- map["isEmailVerified"]
        insuranceName <- map["insuranceName"]
        insuranceID <- map["insuranceId"]
        insuranceNumber <- map["insuranceNumber"]
        insuranceDate <- map["insuranceExpiryDate"]
        isPhoneVerified <- map["phoneVerified"]
//        signStatus <- map["signUpState"]
//        chronicMedications <- map["chronicMedications"]
//        chronicDiseases <- map["chronicDiseases"]
//        userRating <- map["userRating"]
//        signUpState <- map["signUpState"]
//        if let str = profileUrl, let url = URL(string: str) {
//            UserDefaultsConstant.myProfileImage.setValue(value: str)
//            profileImageURL = url
//        }
        
        gender <- map["gender"]
//        roleName <- (map["roleName"], EnumTransform<AppRoleTypeConstants>())
//        signupType <- (map["signupType"], EnumTransform<AppLoginTypeConstants>())
//
//        UserDefaultsConstant.credit.setValue(value: credit)
//
//        if gender.lowercased() == "male" {
//            gender = "edit.male".localized
//        } else if gender.lowercased() == "female" {
//            gender = "edit.female".localized
//        } else if gender.lowercased() == "other" {
//            gender = "edit.other".localized
//        }
//        UserDefaultsConstant.gender.setValue(value: gender)
//
//        if let auth = authToken {
//            if !auth.isEmpty {
//                UserDefaultsConstant.AuthToken.setValue(value: auth)
//            }
//        }
//
//        if let refresh = refreshToken {
//            if !refresh.isEmpty {
//                UserDefaultsConstant.refreshToken.setValue(value: refresh)
//            }
//        }
//
//        if let userID = userId {
//            if !userID.isEmpty {
//                UserDefaultsConstant.UserID.setValue(value: userID)
//            }
//        }
//
//        if let role = roleName {
//            UserDefaultsConstant.RoleName.setValue(value: role.rawValue)
//        }
//
//        if  dob != 0 {
//            let date = Date(timeIntervalSince1970: TimeInterval(Int64(dob/1000)))
//            dobStr = DateUtility.stringFromDateDOB(fromDate: date, dateFormat: DateFormats.dayMonthNameYear.rawValue)
//            UserDefaultsConstant.DOB.setValue(value: dob)
//        }
//
//        if let insuranceTimeStamp = insuranceDate {
//            if insuranceDate == 0 || insuranceDate == nil {
//                insuranceDateStr = " "
//            } else {
//                let date = Date(timeIntervalSince1970: TimeInterval(Int64(insuranceTimeStamp/1000)))
//                insuranceDateStr = DateUtility.stringFromDateDOB(fromDate: date, dateFormat: DateFormats.dayMonthNameYear.rawValue)
//            }
//        }
//
//        if let isSubscribed = isUserSubscribed {
//            UserDefaultsConstant.isUserSubscribed.setValue(value: isSubscribed)
//        }
//
//        if let country = countryNameISO {
//            let isFromUSA = country == "USA" ? true : false
//            UserDefaultsConstant.isFromUSA.setValue(value: isFromUSA)
//        }
//
//        if let sendbirdID = userId?.getSHA256String() {
//            sendBirdId = sendbirdID
//            UserDefaultsConstant.sendBirdID.setValue(value: sendBirdId)
//            print("****sendBirdID: ", sendbirdID)
//        }
//
//        if let isEmailVerified = self.isEmailVerified {
//            UserDefaultsConstant.isEmailVerified.setValue(value: isEmailVerified)
//        }
//
//        if let phoneVerified = self.isPhoneVerified {
//            UserDefaultsConstant.isPhoneVerified.setValue(value: phoneVerified)
//            UserModel.shared.phoneVerified = phoneVerified
//        }
//
//        if let insuranceName = self.insuranceName {
//            UserDefaultsConstant.insuranceName.setValue(value: insuranceName)
//        }
//
//        if let currency = self.creditCurrency {
//            UserModel.shared.currency = currency.localized
//            UserDefaultsConstant.currency.setValue(value: currency.localized)
//        }
//
//        if let status = self.signStatus {
//            UserDefaultsConstant.signUpState.setValue(value: SignUpState.init(rawValue: status.rawValue)?.getValue())
//        }
    }

}

import Foundation
import RxSwift
import Alamofire
public protocol loginDelegate {
    func getLoginData(login: LoginModel)
}

@objc
public class EMBERPod: NSObject {
    let disposeBag = DisposeBag()
    let delegate: loginDelegate? = nil
    
    @objc public class var sharedInstance: EMBERPod {
        struct Singleton {
            static let instance = EMBERPod.init()
        }
        return Singleton.instance
    }
    
    @objc public func getNibFile() -> [Any]? {
        print("hello nib")
        return Bundle(for: NewViewController.self).loadNibNamed("\(NewViewController.self)", owner: self, options: .none)
    }
    
    @objc public func login(loginParameters: [String: Any]) {
        rx_loginToUserAccount(parameters: loginParameters).asObservable().subscribe(onNext: { (response) in
            if let d = self.delegate {
                d.getLoginData(login: response)
            }
            //API success
            print(response)
            
        }, onError: { (error) in
            print(error)
            
            
        }, onCompleted: {
            
        }).disposed(by: disposeBag)
    }
    
    @objc public func getVideoCall(sessionID: String, patientToken: String, providerName: String, providerProfession: String, seconds: Int) -> UIViewController {
        print("getVideoCall")
        
//        let bundleName = Bundle.init(identifier: "TestResourceBundle")
        
        print(UIStoryboard.init(name: "VideoCall", bundle: nil).instantiateViewController(withIdentifier: "VideoCallViewController"))
        
        let videoCallVC = UIStoryboard.init(name: "VideoCall", bundle: nil).instantiateViewController(withIdentifier: "VideoCallViewController") as! VideoCallViewController
        
        videoCallVC.kSessionId = sessionID
        videoCallVC.kToken = patientToken
        
        videoCallVC.videoTitle = providerName
        videoCallVC.videoSubTitle = providerProfession
        print("1st seconds")
        print(seconds)
        videoCallVC.seconds = seconds
        
        return videoCallVC as UIViewController
    }
    
    func rx_loginToUserAccount(parameters: [String: Any]) -> Observable<LoginModel> {
        
        let url: URL = URL.init(string: "https://api-dev.embermed.com/api/v4/patient/login")!
            return ConnectionManager.sharedInstance.request(.post, url, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeaderData(), mapTo: LoginModel.self)
    }
    
     func getHeaderData() -> HTTPHeaders {
        var parameters: HTTPHeaders = [:]

        let DEVICE_ID = "deviceId"
        let ACCEPT_LANGUAGE = "Accept-Language"
        let APP_VERSION = "appVersion"
        let DEVICE_TYPE = "deviceType"
        let CONTENT_TYPE = "content-Type"
//        let DEVICE_NAME = "deviceName"
//        let AUTHORIZATION = "Authorization"
        let origin_Country = "Origin-Country"
        let zoneId = "Zone-Id"

        parameters[CONTENT_TYPE] = "application/json"
        parameters[DEVICE_ID] = UIDevice.current.identifierForVendor?.uuidString ?? ""
        parameters[ACCEPT_LANGUAGE] = "en"
        let infoDict: [AnyHashable: Any]? = Bundle.main.infoDictionary
        let versionBuild: String? = "\(infoDict?["CFBundleShortVersionString"] as? String ?? "")\(infoDict?["CFBundleVersion"] as? String ?? "")"

        parameters[APP_VERSION] = versionBuild ?? ""
//        parameters[DEVICE_NAME] = UIDevice.current.modelName

        parameters[DEVICE_TYPE] = "IOS_IPHONE"

//        parameters [AUTHORIZATION] = (UserDefaultsConstant.AuthToken.getValue() as! String)

//        UserDefaultsConstant.originCountry.setValue(value: "QAT")

        parameters[origin_Country] = "EGY"
//        if let zoneID = UserDefaultsConstant.ZoneId.getValue() as? String, !(zoneID.isEmpty) {
//            parameters[zoneId] = zoneID
//        } else {
            parameters[zoneId] = TimeZone.current.identifier
//        }

        return parameters
    }

}





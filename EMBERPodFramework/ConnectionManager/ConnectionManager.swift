//
//  ConnectionManager.swift
//  OsirisBio Provider
//
//  Created by Pramod More on 8/20/18.
//  Copyright © 2018 Biz4Solutions. All rights reserved.
//
// modified
import Foundation
import RxAlamofire
import ObjectMapper
import Alamofire
import RxSwift

public enum APIError: Error {
    
    case custom(message: String)
    case customWith(statusCode: Int)
}

extension APIError: LocalizedError {
    
    var localizedDescription: String {
        switch self {
        
        case .custom(let message):
            return "\(message)"
            
        case .customWith(let statusCode):
            
            switch statusCode {
            
            case 0: return "Please check your internet connection and try again."
                
            case 401:
                return "Your session was expired. Please login again. Error Code \(statusCode)"
                
            case 500:
                return "Internal server error. Please try again later. Error Code \(statusCode)"
                
            default:
                return "Server could not find requested data. Error Code \(statusCode)"
            }
        }
    }
}

enum ApiErrorCode: Int {
    case unauthorisedUser = 401
    case accessDenied = 403
    case accountBlocked = 410
}

protocol OsirisErrorProtocol: LocalizedError {
    
    var title: String? { get }
    var code: Int { get }
}

struct CustomError: OsirisErrorProtocol {
    
    var title: String?
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }
    
    private var _description: String
    
    init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}

enum AlamofireMessages: String {
    case ERROR_00 = "Could not connect to the server."
    case REQUEST_TIMEDOUT_MESSAGE = "the request timed out."
    case ERROR_JSON = "JSON could not be serialized because of error: The datacould'tbe read because it isn't in the correct format."
    case ERROR_SERVER_NOT_FOUND = "A server with the specified hostname could not be found."
    case ERROR_CANCELLED = "cancelled" // Unknown error due to authorization fail.
    case NO_INTERNET_MESSAGES = "the internet connection appears to be offline."
}

struct BaseMap<T: Mappable> {
    var item: T.Type
    
}

class ConnectionManager {
    
    static var lastRequest = [DataRequest]()
    
    var operationQueue = OperationQueue()
    // SingleInstance
    class var sharedInstance: ConnectionManager {
        struct Singleton {
            static let instance = ConnectionManager.init()
        }
        return Singleton.instance
    }
    
    let disposeBag = DisposeBag()
    
    private let lock = NSLock()
    private var requestsToRetry: [(RetryResult) -> Void] = []
    private var isRefreshing = false
    
    var sessionManager: Session!
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?) -> Void
    
    private init() {
        sessionManager = AF
    }
    
    
    func EMBERPrint(_ log: String) {
            print(log)
            NSLog(log)
    }
    
    
    func request<T: Mappable>(_ method: Alamofire.HTTPMethod,
                              _ url: URLConvertible,
                              parameters: [String: Any]? = nil,
                              encoding: ParameterEncoding = URLEncoding.default,
                              headers: HTTPHeaders? = nil, mapTo: T.Type? = nil) -> Observable<T> {
        
        return Observable.create { observer in
            
            do {
                self.EMBERPrint("******* API URL is \(try url.asURL().absoluteString)")
            } catch {
                self.EMBERPrint("******* API URL is \(url)")
            }
            self.EMBERPrint("******* Parameters are \(String(describing: parameters))")
            self.EMBERPrint("******* Headers are \(String(describing: headers))")
            self.EMBERPrint("******* MAP TO \(String(describing: mapTo))")
            
            var allowedStatusCodes = Set(100..<6000)
            //            allowedStatusCodes.remove(403)
            allowedStatusCodes.remove(401)
            allowedStatusCodes.insert(-1009)

            let request = AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: self).validate(statusCode: allowedStatusCodes).responseJSON { (response) in
                
                self.EMBERPrint("\n******* For REQUEST \(String(describing: response.request?.url?.absoluteString)) \n******Status code is \(String(describing: response.response?.statusCode)) \n******* response is \(String(describing: response))")
                
                switch response.result {
                case .success(let value):
                    
//                    if ( response.response?.statusCode == ApiErrorCode.accessDenied.rawValue || response.response?.statusCode == ApiErrorCode.accountBlocked.rawValue)  && UserDefaultsUtility.isUserLoggedIn() {
                    if ( response.response?.statusCode == ApiErrorCode.accessDenied.rawValue || response.response?.statusCode == ApiErrorCode.accountBlocked.rawValue) {

                        // logout from app
//                        AppManager.shared.autoLogoutUser()
                    } else if response.response?.statusCode != 200 && response.response?.statusCode != 300 {
                        if let statusCode = response.response?.statusCode {
                            if let data = Mapper<ErrorModel>().map(JSONObject: value) {
                                if let msg = data.errorMessage, let code = data.errorCode {
                                    let error = CustomError(title: "", description: msg, code: code)
                                    observer.onError(error)
                                } else if (!data.message.isEmpty) && (data.code != 0) {
                                    let error = CustomError(title: "", description: data.message, code: data.code)
                                    observer.onError(error)
                                } else {
                                    let error = CustomError(title: "", description: APIError.customWith(statusCode: (statusCode)).localizedDescription, code: statusCode)
                                    observer.onError(error)
                                }
                            } else {
                                let error = CustomError(title: "", description: APIError.customWith(statusCode: (statusCode)).localizedDescription, code: statusCode)
                                observer.onError(error)
                            }
                        }
                        
                    } else if response.response?.statusCode == 200 || response.response?.statusCode == 300 {
                        if let data = Mapper<BaseModel>().map(JSONObject: value) {
                            
//                            if (data.code == ApiErrorCode.accessDenied.rawValue || data.code == ApiErrorCode.accountBlocked.rawValue) && UserDefaultsUtility.isUserLoggedIn() {
//                                // logout from app
//                                AppManager.shared.autoLogoutUser()
//                            }
                        }
                        
                        if let dataObject = Mapper<T>().map(JSONObject: value) {
                            if dataObject is BaseModel {
                                (dataObject as! BaseModel).code = response.response?.statusCode ?? 200
                                (dataObject as! BaseModel).timestamp = Int64((response.response?.allHeaderFields["timestamp"] as? String) ?? "0")
                            }
                            observer.onNext(dataObject)
                            observer.onCompleted()
                        } else {
                            let error = CustomError(title: "", description: "Unable to fetch valid data from server. Please try again later. \(String(describing: response.response?.statusCode))", code: 0)
                            observer.onError(error)
                        }
                    }
                case .failure(let error):
                    self.EMBERPrint("Error while fetching remote data: \(String(describing: error.localizedDescription))")
                    
//                    if ( response.response?.statusCode == ApiErrorCode.accessDenied.rawValue || response.response?.statusCode == ApiErrorCode.accountBlocked.rawValue)  && UserDefaultsUtility.isUserLoggedIn() {
//                        AppManager.shared.autoLogoutUser()
//                    }
                    
                    if let statusCode = response.response?.statusCode {
                        let error = CustomError(title: "", description: APIError.customWith(statusCode: (statusCode)).localizedDescription, code: statusCode)
                        observer.onError(error)
                    } else {
                        if error.localizedDescription.lowercased() == AlamofireMessages.NO_INTERNET_MESSAGES.rawValue {
                            
                            let error = CustomError(title: "", description: APIError.customWith(statusCode: (0)).localizedDescription, code: 0)
                            observer.onError(error)
                        } else {
                            let error = CustomError(title: "", description: "\("server.error") Error Code \(String(describing: response.response?.statusCode))", code: 0)
                            observer.onError(error)
                        }
                    }
                }
            }
            print("REQUEST = \(request)")
            return Disposables.create()
        }
    }
    
    func getError(title: String, description: String) {
        
    }
    
    func requestMapArray<T: Mappable>(_ method: Alamofire.HTTPMethod,
                                      _ url: URLConvertible,
                                      parameters: [String: Any]? = nil,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      headers: HTTPHeaders? = nil, mapTo: T.Type? = nil) -> Observable<[T]> {
        
        return Observable.create { observer in
            
            do {
                self.EMBERPrint("******* API URL is \(try url.asURL().absoluteString)")
            } catch {
                self.EMBERPrint("******* API URL is \(url)")
            }
            self.EMBERPrint("******* Parameters are \(String(describing: parameters))")
            self.EMBERPrint("******* Headers are \(String(describing: headers))")
            self.EMBERPrint("******* MAP TO \(String(describing: mapTo))")
            
            var allowedStatusCodes = Set(100..<6000)
            //                       allowedStatusCodes.remove(403)
            allowedStatusCodes.remove(401)
            
            let request = AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: self).validate(statusCode: allowedStatusCodes).responseJSON { (response) in
                
                self.EMBERPrint("\n******* For REQUEST \(String(describing: response.request?.url?.absoluteString)) \n******Status code is \(String(describing: response.response?.statusCode)) \n******* response is \(String(describing: response))")
                
                switch response.result {
                case .success(let value):
                    
//                    if ( response.response?.statusCode == ApiErrorCode.accessDenied.rawValue || response.response?.statusCode == ApiErrorCode.accountBlocked.rawValue)  && UserDefaultsUtility.isUserLoggedIn() {
//                        // logout from app
//                        AppManager.shared.autoLogoutUser()
                    if false {
                    } else if response.response?.statusCode != 200 {
                        if let statusCode = response.response?.statusCode {
                            if let data = Mapper<ErrorModel>().map(JSONObject: value) {
                                if let msg = data.errorMessage, let code = data.errorCode {
                                    let error = CustomError(title: "", description: msg, code: code)
                                    observer.onError(error)
                                } else if (!data.message.isEmpty) && (data.code != 0) {
                                    let error = CustomError(title: "", description: data.message, code: data.code)
                                    observer.onError(error)
                                } else {
                                    let error = CustomError(title: "", description: APIError.customWith(statusCode: (statusCode)).localizedDescription, code: statusCode)
                                    observer.onError(error)
                                }
                            } else {
                                let error = CustomError(title: "", description: APIError.customWith(statusCode: (statusCode)).localizedDescription, code: statusCode)
                                observer.onError(error)
                            }
                        }
                    } else {
                        if (value as? [[String: Any]]) != nil {
                            
                            let statusCode = response.response?.statusCode
//                            if (statusCode == ApiErrorCode.accessDenied.rawValue || statusCode == ApiErrorCode.accountBlocked.rawValue) && UserDefaultsUtility.isUserLoggedIn() {
//
//                                // logout from app
//                                AppManager.shared.autoLogoutUser()
//                            }
                        }
                        
                        if let responseArray = value as? [[String: Any]] {
                            let dataObject = Mapper<T>().mapArray(JSONArray: responseArray)
                            
                            if dataObject is [BaseModel] {
                                if !dataObject.isEmpty {
                                    (dataObject[0] as! BaseModel).code = response.response?.statusCode ?? 200
                                    (dataObject[0] as! BaseModel).timestamp = Int64((response.response?.allHeaderFields["timestamp"] as? String) ?? "0")
                                }
                            }
                            
                            if dataObject is [BaseArrayModel] {
                                if !dataObject.isEmpty {
                                    (dataObject[0] as! BaseArrayModel).currentPage = Int(response.response?.allHeaderFields["x-current-page"] as? String ?? "0") ?? 0
                                    (dataObject[0] as! BaseArrayModel).totalCount = Int(response.response?.allHeaderFields["x-total-count"] as? String ?? "0") ?? 0
                                    (dataObject[0] as! BaseArrayModel).hasMore = Bool(response.response?.allHeaderFields["x-has-more"] as? String ?? "false")
                                    
                                    self.EMBERPrint("hasMore \(String(describing: (dataObject[0] as! BaseArrayModel).hasMore))")
                                    self.EMBERPrint("currentPage \((dataObject[0] as! BaseArrayModel).currentPage)")
                                    self.EMBERPrint("totalCount \((dataObject[0] as! BaseArrayModel).totalCount)")

                                }
                            }
                            
                            observer.onNext(dataObject)
                            observer.onCompleted()
                        } else {
                            let error = CustomError(title: "", description: "Unable to fetch valid data from server. Please try again later. \(String(describing: response.response?.statusCode))", code: 0)
                            observer.onError(error)
                        }
                    }
                case .failure(let error):
                    self.EMBERPrint("Error while fetching remote data: \(String(describing: error.localizedDescription))")
                    
//                    if ( response.response?.statusCode == ApiErrorCode.accessDenied.rawValue || response.response?.statusCode == ApiErrorCode.accountBlocked.rawValue)  && UserDefaultsUtility.isUserLoggedIn() {
//                        
//                        AppManager.shared.autoLogoutUser()
//                    }
                    
                    if let statusCode = response.response?.statusCode {
                        
                        let error = CustomError(title: "", description: APIError.customWith(statusCode: (statusCode)).localizedDescription, code: statusCode)
                        observer.onError(error)
                    } else {
                        if error.localizedDescription.lowercased() == AlamofireMessages.NO_INTERNET_MESSAGES.rawValue {
                            
                            let error = CustomError(title: "", description: APIError.customWith(statusCode: (0)).localizedDescription, code: 0)
                            observer.onError(error)
                        } else {
                            let error = CustomError(title: "", description: "\("server.error") Error Code \(String(describing: response.response?.statusCode))", code: 0)
                            observer.onError(error)
                        }
                    }
                }
            }
            
            print("REQUEST = \(request)")
            
            return Disposables.create()
        }
    }
    
}

extension ConnectionManager: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        if adaptedRequest.url?.absoluteString.contains("api.ipstack.com") ?? false {
            self.EMBERPrint("ADAPT REQUEST api.ipstack.com")
            completion(.success(adaptedRequest))
        } else {
//            if UserDefaultsUtility.isUserLoggedIn() {
//                self.EMBERPrint("ADAPT REQUEST \(String(describing: urlRequest.url?.absoluteString))")
//                guard let token = UserDefaultsConstant.AuthToken.getValue() as? String else {
//                    completion(.success(adaptedRequest))
//                    return
//                }
//
//                adaptedRequest.setValue(token, forHTTPHeaderField: "Authorization")
//                completion(.success(adaptedRequest))
            if false { } else {
                self.EMBERPrint("ADAPT User not Logged In")
                completion(.success(adaptedRequest))
            }
        }
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        lock.lock() ; defer { lock.unlock() }
        print("should retry request")
        self.EMBERPrint("RETRY REQUEST \(request)")
        self.EMBERPrint("RETRY Error \(error)")
        self.EMBERPrint("RETRY Response \(String(describing: request.response))")
        
        if let code = request.response?.statusCode, let message = request.response {
            self.EMBERPrint("RETRY Error message \(message)")
            self.EMBERPrint("RETRY Error code \(code)")
        }
        
//        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 && UserDefaultsUtility.isUserLoggedIn() {
//            // get token
//            requestsToRetry.append(completion)
//
//            if !isRefreshing {
//                refreshTokens { [weak self] succeeded, _ in
//                    guard let strongSelf = self else { return }
//                    self.EMBERPrint("will refresh")
//
//                    guard succeeded == true else {
//                        // calling logout won't work
//                        UserDefaultsUtility.logout()
//                        AppManager.shared.goToLogin()
//                        return
//                    }
//
//                    self.EMBERPrint("refreshing")
//
//                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
//
//                    strongSelf.requestsToRetry.forEach { $0(.retry) }
//                    strongSelf.requestsToRetry.removeAll()
//                }
//            }
            
        if false {} else {
            
//            EZLoadingActivity.hide()

            let nsError = error as NSError
            
            if nsError.domain == "NSPOSIXErrorDomain" && nsError.code == 53 {
                self.EMBERPrint("🚧retrying, Software caused connection abort")
                completion(.retry)
            }
            
            if nsError.domain == "NSURLErrorDomain" && nsError.code == -1005 {
                self.EMBERPrint("🚧retrying, network connection was lost")
                completion(.retry)
            }
            
            self.EMBERPrint("RETRY doNotRetryWithError")

//            DispatchQueue.main.async {
//                let banner = GrowingNotificationBanner(title: NSLocalizedString("error", comment: ""), subtitle: error.localizedDescription, style: .danger )
//                banner.show()
//            }
            completion(.doNotRetryWithError(error))
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
//    private func refreshTokens(completion: @escaping RefreshCompletion) {
//        guard !isRefreshing else { return }
//
//        isRefreshing = true
//
//        var url = URLComponents(string: AppBackendAPI_URLs.refreshToken.getURLfor().absoluteString) ?? URLComponents()
//        url.queryItems = [
//            URLQueryItem(name: "accessToken", value: (UserDefaults.standard.value(forKey: UserDefaultsConstant.AuthToken.rawValue) as? String) ?? ""),
//            URLQueryItem(name: "refreshToken", value: (UserDefaults.standard.value(forKey: UserDefaultsConstant.refreshToken.rawValue) as? String) ?? "")
//        ]
//
//        let reqHeader: HTTPHeaders = ["Accept-Language": L102Language.currentAppleLanguage(), "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "", "Authorization": ""]
//
//        print("url \n \(url)")
//
//        AF.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: reqHeader ).responseJSON { [weak self] response in
//            guard let strongSelf = self else { return }
//
//            self.EMBERPrint("******* For refreshTokens REQUEST \(String(describing: response.request?.url?.absoluteString)) ******Status code is \(String(describing: response.response?.statusCode)) \n******* refreshTokens response is \(response)")
//
//            switch response.result {
//            case .success(let value):
//                if response.response?.statusCode == 200 {
//                    // Update the tokens in userDefualts
//                    let dataObject = Mapper<RefreshTokenModel>().map(JSONObject: value)
//                    UserDefaultsConstant.AuthToken.setValue(value: dataObject?.authToken)
//                    UserDefaultsConstant.refreshToken.setValue(value: dataObject?.refreshToken)
//                    self.EMBERPrint("REFRESHED DONE, Re Save the tokens, make latest call")
//                    completion(true, nil)
//                } else {
//                    self.EMBERPrint("REFRESH LOGOUT")
//                    completion(false, nil)
//                }
//            case .failure(let error):
//                self.EMBERPrint("REFRESH LOGOUT")
//                self.EMBERPrint("\(error.localizedDescription)")
//
//                completion(false, nil)
//            }
//
//            strongSelf.isRefreshing = false
//        }
//    }
}

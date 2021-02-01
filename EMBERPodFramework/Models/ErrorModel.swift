//
//  errorModel.swift
//  OsirisBio
//
//  Created by Esraa Hamed on 10/24/19.
//  Copyright © 2019 EMBER Medical. All rights reserved.
//
import Foundation
import RxAlamofire
import ObjectMapper

class ErrorModel: BaseModel {
    var errorMessage, errorDetails: String?
    var errorCode: Int?

    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        errorMessage <- map["errorMessage"]
        errorDetails <- map["errorDetails"]
        errorCode <- map["errorCode"]
    }
    
}

public enum RequestType: String, Codable {
    
    case TELEHEALTH_BROADCAST
    case TELEHEALTH_DIRECTED
    case LIVE_CHAT_BROADCAST
    case LIVE_CHAT_DIRECTED
    case LAB_REQUEST
    case APPOINTMENT
    case UnKnown
    
    func getValue() -> String {
        switch self {
        case .TELEHEALTH_BROADCAST: return "TELEHEALTH_BROADCAST"
        case .TELEHEALTH_DIRECTED: return "TELEHEALTH_DIRECTED"
        case .LIVE_CHAT_BROADCAST: return "LIVE_CHAT_BROADCAST"
        case .LIVE_CHAT_DIRECTED: return "LIVE_CHAT_DIRECTED"
        case .LAB_REQUEST: return "LAB_REQUEST"
        case .APPOINTMENT: return "APPOINTMENT"
        case .UnKnown : return ""
        }
    }
    
    func readable() -> String {
        switch self {
        case .TELEHEALTH_BROADCAST, .TELEHEALTH_DIRECTED:
            return "TelehealthRequest".localized
            
        case .LIVE_CHAT_BROADCAST, .LIVE_CHAT_DIRECTED:
            return "LiveChatRequest".localized
        case .LAB_REQUEST:
            return "LAB_REQUEST".localized
        case .APPOINTMENT:
            return "appointment.request".localized
        case .UnKnown:
            return ""
        }
    }
    
    func readbleInIncidentReport() -> String {
        switch self {
        case .TELEHEALTH_BROADCAST, .TELEHEALTH_DIRECTED:
            return "audio/video.call".localized
            
        case .LIVE_CHAT_BROADCAST, .LIVE_CHAT_DIRECTED:
            return "audio/video.chat".localized
        case .LAB_REQUEST:
            return "LAB_REQUEST".localized
        case .APPOINTMENT:
            return "appointment.request".localized
        case .UnKnown:
            return ""
        }
    }
    
    func filterReadbleString() -> String {
        switch self {
        case .TELEHEALTH_BROADCAST, .TELEHEALTH_DIRECTED:
            return "telehealth.call".localized
            
        case .LIVE_CHAT_BROADCAST, .LIVE_CHAT_DIRECTED:
            return "Chat.Requests".localized
        case .LAB_REQUEST:
            return "lab.Tests".localized
        case .APPOINTMENT:
            return "appointment.request".localized
        case .UnKnown:
            return ""
        }
    }
    
    func intercomeReadableString() -> String {
        switch self {
        case .TELEHEALTH_BROADCAST, .TELEHEALTH_DIRECTED:
            return "Video Call"
            
        case .LIVE_CHAT_BROADCAST, .LIVE_CHAT_DIRECTED:
            return "Live Chat"
        case .LAB_REQUEST:
            return "lab tests"
        case .APPOINTMENT:
            return "Appointment"
        case .UnKnown:
            return ""
        }
    }
}

extension RequestType {
    init?(string: String) {
        switch string {
        case "TELEHEALTH_BROADCAST": self = .TELEHEALTH_BROADCAST
        case "TELEHEALTH_DIRECTED": self = .TELEHEALTH_DIRECTED
        case "LIVE_CHAT_BROADCAST": self = .LIVE_CHAT_BROADCAST
        case "LIVE_CHAT_DIRECTED": self = .LIVE_CHAT_DIRECTED
        case "LAB_REQUEST":self = .LAB_REQUEST
        case "APPOINTMENT": self = .APPOINTMENT
        case "" :self = .UnKnown
        default:
            return nil
        }
    }
}

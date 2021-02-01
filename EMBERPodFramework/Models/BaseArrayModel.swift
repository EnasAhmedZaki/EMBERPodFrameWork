//
//  BaseArrayModel.swift
//  OsirisBio
//
//  Created by Esraa Hamed on 9/30/19.
//  Copyright © 2019 EMBER Medical. All rights reserved.
//

import Foundation
import RxAlamofire
import ObjectMapper

class BaseArrayModel: BaseModel {
    var currentPage: Int = 0
    var totalCount = 0
    var hasMore: Bool?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override init() {
        super.init()
    }
    
    override func mapping(map: Map) {
        currentPage <- map["x-current-page"]
        totalCount <- map["x-total-count"]
        hasMore <- map["x-has-more"]
    }
    
}

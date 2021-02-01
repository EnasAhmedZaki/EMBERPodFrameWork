//
//  Logging.swift
//  OsirisBio Provider
//
//  Created by Enas Ahmed Zaki on 4/16/20.
//  Copyright © 2020 EMBER Medical. All rights reserved.
//

import UIKit

func EMBERPrint(_ log: String) {
//    if EnvironmentConfiguration.sharedInstance.environment != EnvType.Prod {
        print(log)
        NSLog(log)
//    }
}

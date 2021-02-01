//
//  extensionStrings.swift
//  OsirisBioUser
//
//  Created by Pramod More on 7/27/18.
//  Copyright © 2018 Biz4Solutions. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

var st = "false"

extension String {
    func toBool() -> Bool {
        if self == "false" {
            return false
        } else {
            return true
        }
    }
}

struct Name {
    let first: String
    let last: String

    init(first: String, last: String) {
        self.first = first
        self.last = last
    }
}

extension Name {
    init(fullName: String) {
        var names = fullName.components(separatedBy: " ")
        let first = names.removeFirst()
        let last = names.joined(separator: " ")
        self.init(first: first, last: last)
    }
}

extension Name: CustomStringConvertible {
    var description: String { return "\(first) \(last)" }
}

extension String {
    var localizeString: String {
        return NSLocalizedString(self, comment: "")
    }

    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last ?? ""
    }

    func substring(_ from: Int) -> String {
        let myNSString = self as NSString
        return myNSString.substring(with: NSRange(location: 0, length: self.length))
        // return self.substring(from: self.index(self.startIndex, offsetBy: from))
    }

    var length: Int {
        return self.count
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.height
    }

    func getRequiredWidth(font: UIFont) -> CGFloat {

        // var originalString: String = "Some text is just here..."
        let myString: NSString = self as NSString
        let size: CGSize = myString.size(withAttributes: [NSAttributedString.Key.font: font])
        return size.width
    }
}

extension String {
    func getSHA256() -> Data? {
        guard let messageData = self.data(using: String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData
    }
    func getSHA256String() -> String? {

        guard let SHA256Data = self.getSHA256() else {
            return nil
        }

        return SHA256Data.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    func arabicNumberToEnglish() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "EN")
        
        if numberFormatter.number(from: self) != nil {
            var str = self
            let map = ["٠": "0",
                       "١": "1",
                       "٢": "2",
                       "٣": "3",
                       "٤": "4",
                       "٥": "5",
                       "٦": "6",
                       "٧": "7",
                       "٨": "8",
                       "٩": "9"]
            
            map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
            return str
        }
        return self
    }
    func localizingTheNumbers() -> String {
        if L102Language.currentAppleLanguage() != "ar" {
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = Locale(identifier: "EN")
            
                var str = self
                let map = ["٠": "0",
                           "١": "1",
                           "٢": "2",
                           "٣": "3",
                           "٤": "4",
                           "٥": "5",
                           "٦": "6",
                           "٧": "7",
                           "٨": "8",
                           "٩": "9"]
                
                map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
                return str
           
        } else if L102Language.currentAppleLanguage() == "ar" {
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = Locale(identifier: "EN")
            
                var str = self
                let map = ["0": "٠",
                           "1": "١",
                           "2": "٢",
                           "3": "٣",
                           "4": "٤",
                           "5": "٥",
                           "6": "٦",
                           "7": "٧",
                           "8": "٨",
                           "9": "٩"]
                
                map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
                return str
        }
        return self

    }
    
}

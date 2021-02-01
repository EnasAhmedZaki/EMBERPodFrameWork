//
//  StoryBoardLocalizable.swift
//  OsirisBioUser
//
//  Created by Pramod More on 7/27/18.
//  Copyright © 2018 Biz4Solutions. All rights reserved.
//
//https://github.com/emenegro/xib-localization/blob/master/LocalizationBlog/Localizable.swift
import Foundation
import UIKit
import SkyFloatingLabelTextField

// MARK: Localizable
public protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: XIBLocalizable
public protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
    
    @IBInspectable public var xibLocImg: String? {
        get { return nil }
        set(key) {
            setImage(UIImage(named: key?.localized ?? ""), for: .normal)
        }
    }
    
}

extension UIImageView: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            image = UIImage(named: key?.localized ?? "")
        }
    }
    
}

public protocol UITextViewXIBLocalizable {
    var xibPlaceholderLocKey: String? { get set }
}
//extension UITextView: UITextViewXIBLocalizable {
//
//    @IBInspectable public var xibPlaceholderLocKey: String? {
//        get { return nil }
//        set(key) {
//            placeholder = key?.localized
//        }
//    }
//}

extension UINavigationItem: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
        }
    }
}

extension UIBarItem: XIBLocalizable { // Localizes UIBarButtonItem and UITabBarItem
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
        }
    }
}

// MARK: Special protocol to localize multiple texts in the same control
public protocol XIBMultiLocalizable {
    var xibLocKeys: String? { get set }
}

extension UISegmentedControl: XIBMultiLocalizable {
    @IBInspectable public var xibLocKeys: String? {
        get { return nil }
        set(keys) {
            guard let keys = keys?.components(separatedBy: ","), !keys.isEmpty else { return }
            for (index, title) in keys.enumerated() {
                setTitle(title.localized, forSegmentAt: index)
            }
        }
    }
}

// MARK: Special protocol to localizaze UITextField's placeholder
public protocol UITextFieldXIBLocalizable {
    var xibPlaceholderLocKey: String? { get set }
    
}

extension UITextField: UITextFieldXIBLocalizable {
    @IBInspectable public var xibPlaceholderLocKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized
        }
    }
}

public protocol SkyFloatTextLocalizable {
    var xibSkyTitleLocKey: String? { get set }
    var xibSkySelectedTitleLocKey: String? { get set }
}

extension SkyFloatingLabelTextField: SkyFloatTextLocalizable {
    @IBInspectable public var xibSkySelectedTitleLocKey: String? {
        get { return nil }
        set(key) {
            selectedTitle = key?.localized
            
        }
    }
    
    @IBInspectable public var xibSkyTitleLocKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
            
        }
    }
}

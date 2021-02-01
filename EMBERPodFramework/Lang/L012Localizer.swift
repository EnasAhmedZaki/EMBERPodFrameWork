//
//  Localizer.swift
//  Localization102
//
//  Created by Moath_Othman on 2/24/16.
//  Copyright © 2016 Moath_Othman. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    class func isRTL() -> Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
    class func isLTR() -> Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
    }
}

class L102Localizer: NSObject {
    class func DoTheMagic() {
        
        MethodSwizzleGivenClassName(cls: Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(_:value:table:)))
        MethodSwizzleGivenClassName(cls: UIApplication.self, originalSelector: #selector(getter: UIApplication.userInterfaceLayoutDirection), overrideSelector: #selector(getter: UIApplication.cstm_userInterfaceLayoutDirection))
        MethodSwizzleGivenClassName(cls: UITextField.self, originalSelector: #selector(UITextField.layoutSubviews), overrideSelector: #selector(UITextField.cstmlayoutSubviews))
        MethodSwizzleGivenClassName(cls: UILabel.self, originalSelector: #selector(UILabel.layoutSubviews), overrideSelector: #selector(UILabel.cstmlayoutSubviews))
        
        MethodSwizzleGivenClassName(cls: UIButton.self, originalSelector: #selector(UIButton.layoutSubviews), overrideSelector: #selector(UIButton.cstmlayoutSubviews))
        
//        MethodSwizzleGivenClassName(cls: UITextView.self, originalSelector: #selector(UITextView.layoutSubviews), overrideSelector: #selector(UITextView.cstmlayoutSubviews))

        //        MethodSwizzleGivenClassName(cls: UIBarButtonItem.self, originalSelector: #selector(UIBarButtonItem.cstmlayoutSubviews), overrideSelector: #selector(UIBarButtonItem.cstmlayoutSubviews))
        
    }
}

extension UILabel {
    @objc public func cstmlayoutSubviews() {
        self.cstmlayoutSubviews()
        if let className = NSClassFromString("UITextFieldLabel"), self.isKind(of: className) {
            return // handle special case with uitextfields
        }
        if self.tag <= 0 {
            if UIApplication.isRTL() {
                if self.textAlignment == .center { return }
                self.textAlignment = .right
            } else {
                if self.textAlignment == .center { return }
                self.textAlignment = .left
            }
        }
        
    }
}

extension UIViewController {
    func loopThroughSubViewAndFlipTheImageIfItsAUIImageView(subviews: [UIView]) {
        if !subviews.isEmpty {
            for subView in subviews {
                if (subView is UIImageView) && subView.tag < 0 {
                    let toRightArrow = subView as! UIImageView
                    if let _img = toRightArrow.image, let _imgCgImage = _img.cgImage {
                        toRightArrow.image = UIImage(cgImage: _imgCgImage, scale: _img.scale, orientation: UIImage.Orientation.upMirrored)
                    }
                }
                loopThroughSubViewAndFlipTheImageIfItsAUIImageView(subviews: subView.subviews)
            }
        }
    }
}

extension UITextField {
    @objc public func cstmlayoutSubviews() {
        self.cstmlayoutSubviews()
        if self.tag <= 0 {
            if UIApplication.isRTL() {
                if self.textAlignment == .center { return }
                self.textAlignment = .right
            } else {
                if self.textAlignment == .center { return }
                self.textAlignment = .left
            }
        }
    }
}

extension UITextView {
    @objc public func cstmlayoutSubviews() {
        self.cstmlayoutSubviews()
        if self.tag <= 0 {
            if UIApplication.isRTL() {
                if self.textAlignment == .center { return }
                self.textAlignment = .right
            } else {
                if self.textAlignment == .center { return }
                self.textAlignment = .left
            }
        }
    }
}

extension UIButton {
    @objc public func cstmlayoutSubviews() {
        self.cstmlayoutSubviews()
        if self.tag <= 0 {
           /*if UIApplication.isRTL()  {
               if self.contentHorizontalAlignment == .center { return }
           } else if UIApplication.isLTR() {
              if self.contentHorizontalAlignment == .center { return }
           }

           if self.contentHorizontalAlignment == .left {
                self.contentHorizontalAlignment = .right
            } else if self.contentHorizontalAlignment == .right{
                self.contentHorizontalAlignment = .left
           }*/
            
            if UIApplication.isRTL() {
                if self.contentHorizontalAlignment == .center { return }
                self.contentHorizontalAlignment = .right
            } else {
                if self.contentHorizontalAlignment == .center { return }
                self.contentHorizontalAlignment = .left
            }
            
        }
    }
}

extension UIBarButtonItem {
    @objc public func cstmlayoutSubviews() {
        self.cstmlayoutSubviews()
        if UIApplication.isRTL() {
            self.customView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.customView?.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
}

// extension UIViewController {
//    func viewDidLoad() {
//
//        if L102Language.currentAppleLanguage() == "ar" {
//            loopThroughSubViewAndFlipTheImageIfItsAUIImageView(subviews: self.view.subviews)
//        }
//    }
// }

var numberoftimes = 0
extension UIApplication {
    @objc var cstm_userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        var direction = UIUserInterfaceLayoutDirection.leftToRight
        if L102Language.currentAppleLanguage() == "ar" {
            direction = .rightToLeft
        }
        return direction
    }
}

extension Bundle {
    @objc func specialLocalizedStringForKey(_ key: String, value: String?, table tableName: String?) -> String {
        if self == Bundle.main {
            let currentLanguage = L102Language.currentAppleLanguage()
            var bundle = Bundle.main
            if let _path = Bundle.main.path(forResource: L102Language.currentAppleLanguageFull(), ofType: "lproj") {
                bundle = Bundle(path: _path) ?? Bundle.main
            } else
                if let _path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
                    bundle = Bundle(path: _path) ?? Bundle.main
                } else {
                    if let _path = Bundle.main.path(forResource: "en", ofType: "lproj") {
                        bundle = Bundle(path: _path) ?? Bundle.main
                    }
            }
            return (bundle.specialLocalizedStringForKey(key, value: value, table: tableName))
        } else {
            return (self.specialLocalizedStringForKey(key, value: value, table: tableName))
        }
    }
}

func disableMethodSwizzling() {
    
}

/// Exchange the implementation of two methods of the same Class
func MethodSwizzleGivenClassName(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    if let origMethod = class_getInstanceMethod(cls, originalSelector), let overrideMethod = class_getInstanceMethod(cls, overrideSelector) {
        if class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod)) {
            class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod))
        } else {
            method_exchangeImplementations(origMethod, overrideMethod)
        }
    }
}

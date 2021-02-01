//
//  UIImageExtension.swift
//  OsirisBio
//
//  Created by Ahmed on 10/10/19.
//  Copyright © 2019 EMBER Medical. All rights reserved.
//

import Foundation
import UIKit
import WXImageCompress
import ImageIO

/**
 Global variable to enable or disable checking the selected image size,
 Default value is true (enabled),
 If set value to false function "getCompressedImg" will reset value to true after checking.
*/
var checkImageSize: Bool = true

// Comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

extension UIImage {

    func getCompressedImg() -> (Bool, UIImage?) {

        print("actual size of image in MB: ", self.getImageSizeInMB(image: self))

        if self.getImageSizeInMB(image: self) <= 2.0 {
            if let img = self.getCompressedImage() {
                return (true, img)
            }
        }
        
        let numOfIterations = 10
        var comprssedImg = self.wxCompress(type: .timeline)
        var compImgSize = comprssedImg.getImageSizeInMB(image: self)
        print("approx size of compresssed image in MB: ", compImgSize)
        while compImgSize >= 2 && numOfIterations >= 0 {
            comprssedImg = comprssedImg.wxCompress(type: .timeline)
            compImgSize = comprssedImg.getImageSizeInMB(image: comprssedImg)
            print("approx size of compresssed image in MB: ", compImgSize) // this is an approx. image size because we're using
        }
        
        if compImgSize >= 2 {
             return (false, nil)
        } else {
            return (true, comprssedImg)
        }
    }

    func getImageSizeInMB( image: UIImage) -> Double {
        let imgSize = Double(self.jpegData(compressionQuality: 1.0)?.count ?? 0)
        return  imgSize/1024/1024
    }

    func getCompressedImage(compressionQuality: CGFloat = 1.0 ) -> UIImage? {
        if let imgData = self.jpegData(compressionQuality: compressionQuality) {
            let comprssedImg = UIImage(data: imgData)
            return comprssedImg
        }
        return nil
    }
    
    func logImageSizeInKB(scale: CGFloat) -> (Int, Data) {
        let data = self.jpegData(compressionQuality: scale) ?? Data()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useKB
        formatter.countStyle = ByteCountFormatter.CountStyle.file
        let imageSize = formatter.string(fromByteCount: Int64(data.count))
        print("ImageSize(KB): \(imageSize)")

        return (Int(Int64(data.count) / 1024), data)
    }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gifImageWithURL(_ gifUrl: String) -> UIImage? {
        guard let bundleURL: URL = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }

        return gifImageWithData(imageData)
    }

    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gifImageWithData(imageData)
    }

    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)

        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        delay = delayObject as! Double

        if delay < 0.1 {
            delay = 0.1
        }

        return delay
    }

    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if let nonOptionalB = b {
                return nonOptionalB
            } else if let nonOptionalA = a {
                return nonOptionalA
            } else {
                return 0
            }
        }

        if a < b {
            let c = a
            a = b
            b = c
        }

        var rest: Int = 0
        while true {
            if let nonOptionalA = a, let nonOptionalB = b {
                rest = nonOptionalA % nonOptionalB
            }

            if rest == 0 {
                if let nonOptionalB = b {
                    return nonOptionalB
                }
            } else {
                a = b
                b = rest
            }
        }
    }

    class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }

            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
        }()

        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)

        return animation
    }
    
}

extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.height / 2)
        self.layer.masksToBounds = true
    }
}

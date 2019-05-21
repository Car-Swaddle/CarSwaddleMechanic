//
//  UIColorExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//


public typealias RGB = (red: CGFloat, green: CGFloat, blue: CGFloat)
public typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

public extension UIColor {
    
    // MARK: - Convenience Inits
    
    convenience init(red255: UInt8, green255: UInt8, blue255: UInt8, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red255)/255.0, green: CGFloat(green255)/255.0, blue: CGFloat(blue255)/255.0, alpha: alpha)
    }
    
    convenience init(white255: UInt8, alpha: CGFloat = 1.0) {
        self.init(white:CGFloat(white255)/255.0, alpha: alpha)
    }
    
    convenience init(hexString: String) {
        let scanner = Scanner(string: UIColor.normalizeHexString(hexString: hexString))
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let redMask: UInt32    = 0xff000000
        let greenMask: UInt32  = 0x00ff0000
        let blueMask: UInt32   = 0x0000ff00
        let alphaMask: UInt32  = 0x000000ff
        
        let redInt = UInt32(color & redMask) >> 24
        let greenInt = UInt32(color & greenMask) >> 16
        let blueInt = UInt32(color & blueMask) >> 8
        let alphaInt = UInt32(color & alphaMask)
        
        let red   = CGFloat(redInt) / 255.0
        let green = CGFloat(greenInt) / 255.0
        let blue  = CGFloat(blueInt) / 255.0
        let alpha  = CGFloat(alphaInt) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private class func normalizeHexString(hexString: String) -> String {
        var hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }
        if hexString.count == 3 || hexString.count == 4 {
            hexString = hexString.map { "\($0)\($0)" }.joined()
        }
        if hexString.count == 6 {
            hexString = hexString + "ff"
        }
        return hexString
    }
    
    // MARK: - Convenience Functions
    
    class func fromRGB(_ rgb: RGB) -> UIColor {
        let rgba = (red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: CGFloat(1))
        return fromRGBA(rgba)
    }
    
    class func fromRGBA(_ rgba: RGBA) -> UIColor {
        return UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
    
    func rgbaValue() -> RGBA? {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func rgbValue() -> RGB? {
        guard let rgba = rgbaValue() else { return nil }
        return (red: rgba.red, green: rgba.green, blue: rgba.blue)
    }
    
    var hexStringValue: String? {
        guard let colorComponents = cgColor.components,
            let red = colorComponents.safeObject(at: 0),
            let green = colorComponents.safeObject(at: 1),
            let blue = colorComponents.safeObject(at: 2) else { return nil }
        
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
    
    func color(adjustedBy value: CGFloat) -> UIColor {
        guard let rgba = rgbaValue() else { return self }
        return UIColor(red: rgba.red+value, green: rgba.green+value, blue: rgba.blue+value, alpha: rgba.alpha)
    }
    
    func color(adjustedBy255Points points: Int16) -> UIColor {
        return color(adjustedBy: CGFloat(points)/255.0)
    }
    
}

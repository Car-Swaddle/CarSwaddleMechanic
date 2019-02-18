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
    
    // MARK: - Colors
    
    public static let linkColor =  #colorLiteral(red: 0.4431372549, green: 0.7176470588, blue: 0.8980392157, alpha: 1) // Hex: #71B7E5, R: 113, G: 183, B: 229, A: 1.0
    
    public static let appBlue = #colorLiteral(red: 0.4941176471, green: 0.6588235294, blue: 0.9882352941, alpha: 1)
    public static let appGreen = #colorLiteral(red: 0.3607843137, green: 0.7882352941, blue: 0.4196078431, alpha: 1)
    public static let appRed = #colorLiteral(red: 0.9921568627, green: 0.5411764706, blue: 0.4509803922, alpha: 1)
    
    public static let orange1 =  #colorLiteral(red: 0.9921568627, green: 0.9254901961, blue: 0.6784313725, alpha: 1) // Hex: #FDECAD, R: 253, G: 236, B: 173, A: 1.0
    public static let orange2 =  #colorLiteral(red: 0.9882352941, green: 0.8117647059, blue: 0.5176470588, alpha: 1) // Hex: #FCCF84, R: 252, G: 207, B: 132, A: 1.0
    public static let orange3 =  #colorLiteral(red: 0.9843137255, green: 0.6784313725, blue: 0.337254902, alpha: 1) // Hex: #FBAD56, R: 251, G: 173, B:  86, A: 1.0
    public static let orange4 =  #colorLiteral(red: 0.9843137255, green: 0.5529411765, blue: 0.2, alpha: 1) // Hex: #FB8D33, R: 251, G: 141, B:  51, A: 1.0
    public static let orange5 =  #colorLiteral(red: 0.8941176471, green: 0.337254902, blue: 0.1294117647, alpha: 1) // Hex: #E45621, R: 228, G:  86, B:  33, A: 1.0
    public static let orange6 =  #colorLiteral(red: 0.6431372549, green: 0.2156862745, blue: 0.1411764706, alpha: 1) // Hex: #A43724, R: 164, G:  55, B:  36, A: 1.0
    
    public static let red1 =  #colorLiteral(red: 0.9921568627, green: 0.8666666667, blue: 0.8666666667, alpha: 1) // Hex: #FDDDDD, R: 253, G: 221, B: 221, A: 1.0
    public static let red2 =  #colorLiteral(red: 0.9882352941, green: 0.737254902, blue: 0.7176470588, alpha: 1) // Hex: #FCBCB7, R: 252, G: 188, B: 183, A: 1.0
    public static let red3 =  #colorLiteral(red: 0.9921568627, green: 0.6, blue: 0.5764705882, alpha: 1) // Hex: #FD9993, R: 253, G: 153, B: 147, A: 1.0
    public static let red4 =  #colorLiteral(red: 0.9921568627, green: 0.4980392157, blue: 0.462745098, alpha: 1) // Hex: #FD7F76, R: 253, G: 127, B: 118, A: 1.0
    public static let red5 =  #colorLiteral(red: 0.8941176471, green: 0.3450980392, blue: 0.3098039216, alpha: 1) // Hex: #E4584F, R: 228, G:  88, B:  79, A: 1.0
    public static let red6 =  #colorLiteral(red: 0.7882352941, green: 0.1803921569, blue: 0.1450980392, alpha: 1) // Hex: #C92E25, R: 201, G:  46, B:  37, A: 1.0
    
    public static let green1 =  #colorLiteral(red: 0.8666666667, green: 0.9568627451, blue: 0.7294117647, alpha: 1) // Hex: #DDF4BA, R: 221, G: 244, B: 186, A: 1.0
    public static let green2 =  #colorLiteral(red: 0.7333333333, green: 0.8941176471, blue: 0.568627451, alpha: 1) // Hex: #BBE491, R: 187, G: 228, B: 145, A: 1.0
    public static let green3 =  #colorLiteral(red: 0.6274509804, green: 0.8431372549, blue: 0.4431372549, alpha: 1) // Hex: #A0D771, R: 160, G: 215, B: 113, A: 1.0
    public static let green4 =  #colorLiteral(red: 0.5019607843, green: 0.7607843137, blue: 0.3647058824, alpha: 1) // Hex: #80C25D, R: 128, G: 194, B:  93, A: 1.0
    public static let green5 =  #colorLiteral(red: 0.3333333333, green: 0.6196078431, blue: 0.2196078431, alpha: 1) // Hex: #559E38, R:  85, G: 158, B:  56, A: 1.0
    public static let green6 =  #colorLiteral(red: 0.2039215686, green: 0.4823529412, blue: 0.1490196078, alpha: 1) // Hex: #347B26, R:  52, G: 123, B:  38, A: 1.0
    
    public static let aqua1 =  #colorLiteral(red: 0.8470588235, green: 0.9529411765, blue: 0.8705882353, alpha: 1) // Hex: #D8F3DE, R: 216, G: 243, B: 222, A: 1.0
    public static let aqua2 =  #colorLiteral(red: 0.6705882353, green: 0.8941176471, blue: 0.7921568627, alpha: 1) // Hex: #ABE4CA, R: 171, G: 228, B: 202, A: 1.0
    public static let aqua3 =  #colorLiteral(red: 0.5529411765, green: 0.8352941176, blue: 0.7450980392, alpha: 1) // Hex: #8DD5BE, R: 141, G: 213, B: 190, A: 1.0
    public static let aqua4 =  #colorLiteral(red: 0.4117647059, green: 0.7450980392, blue: 0.6588235294, alpha: 1) // Hex: #69BEA8, R: 105, G: 190, B: 168, A: 1.0
    public static let aqua5 =  #colorLiteral(red: 0.2745098039, green: 0.5960784314, blue: 0.5411764706, alpha: 1) // Hex: #46988A, R:  70, G: 152, B: 138, A: 1.0
    public static let aqua6 =  #colorLiteral(red: 0.1333333333, green: 0.4705882353, blue: 0.4470588235, alpha: 1) // Hex: #227872, R:  34, G: 120, B: 114, A: 1.0
    
    public static let blue1 =  #colorLiteral(red: 0.8509803922, green: 0.9215686275, blue: 0.9921568627, alpha: 1) // Hex: #D9EBFD, R: 217, G: 235, B: 253, A: 1.0
    public static let blue2 =  #colorLiteral(red: 0.7176470588, green: 0.8549019608, blue: 0.9607843137, alpha: 1) // Hex: #B7DAF5, R: 183, G: 218, B: 245, A: 1.0
    public static let blue3 =  #colorLiteral(red: 0.5647058824, green: 0.768627451, blue: 0.8941176471, alpha: 1) // Hex: #90C4E4, R: 144, G: 196, B: 228, A: 1.0
    public static let blue4 =  #colorLiteral(red: 0.4470588235, green: 0.6901960784, blue: 0.8431372549, alpha: 1) // Hex: #72B0D7, R: 114, G: 176, B: 215, A: 1.0
    public static let blue5 =  #colorLiteral(red: 0.3058823529, green: 0.5490196078, blue: 0.7294117647, alpha: 1) // Hex: #4E8CBA, R:  78, G: 140, B: 186, A: 1.0
    public static let blue6 =  #colorLiteral(red: 0.1921568627, green: 0.4078431373, blue: 0.6078431373, alpha: 1) // Hex: #31689B, R:  49, G: 104, B: 155, A: 1.0
    
    public static let purple1 =  #colorLiteral(red: 0.9529411765, green: 0.8941176471, blue: 0.9960784314, alpha: 1) // Hex: #F3E4FE, R: 243, G: 228, B: 254, A: 1.0
    public static let purple2 =  #colorLiteral(red: 0.8666666667, green: 0.7843137255, blue: 0.937254902, alpha: 1) // Hex: #DDC8EF, R: 221, G: 200, B: 239, A: 1.0
    public static let purple3 =  #colorLiteral(red: 0.7725490196, green: 0.6745098039, blue: 0.8666666667, alpha: 1) // Hex: #C5ACDD, R: 197, G: 172, B: 221, A: 1.0
    public static let purple4 =  #colorLiteral(red: 0.7019607843, green: 0.568627451, blue: 0.7921568627, alpha: 1) // Hex: #B391CA, R: 179, G: 145, B: 202, A: 1.0
    public static let purple5 =  #colorLiteral(red: 0.5607843137, green: 0.4235294118, blue: 0.7529411765, alpha: 1) // Hex: #8F6CC0, R: 143, G: 108, B: 192, A: 1.0
    public static let purple6 =  #colorLiteral(red: 0.4745098039, green: 0.2509803922, blue: 0.631372549, alpha: 1) // Hex: #7940A1, R: 121, G: 64, B: 161, A: 1.0
    
    public static let pink1 =  #colorLiteral(red: 0.9843137255, green: 0.8509803922, blue: 0.9058823529, alpha: 1) // Hex: #FBD9E7, R: 251, G: 217, B: 231, A: 1.0
    public static let pink2 =  #colorLiteral(red: 0.9843137255, green: 0.7137254902, blue: 0.8666666667, alpha: 1) // Hex: #FBB6DD, R: 251, G: 182, B: 221, A: 1.0
    public static let pink3 =  #colorLiteral(red: 0.9529411765, green: 0.5843137255, blue: 0.8039215686, alpha: 1) // Hex: #F395CD, R: 243, G: 149, B: 205, A: 1.0
    public static let pink4 =  #colorLiteral(red: 0.9333333333, green: 0.462745098, blue: 0.7490196078, alpha: 1) // Hex: #EE76BF, R: 238, G: 118, B: 191, A: 1.0
    public static let pink5 =  #colorLiteral(red: 0.8117647059, green: 0.3176470588, blue: 0.6745098039, alpha: 1) // Hex: #CF51AC, R: 207, G:  81, B: 172, A: 1.0
    public static let pink6 =  #colorLiteral(red: 0.6509803922, green: 0.1647058824, blue: 0.568627451, alpha: 1) // Hex: #A62A91, R: 166, G:  42, B: 145, A: 1.0
    
    // MARK: - Gray Opaque
    
    public static let gray1 =  #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1) // Hex: #F6F6F6, R: 246, G: 246, B: 246, A: 1.0 // gray04
    public static let gray2 =  #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1) // Hex: #EEEEEE, R: 238, G: 238, B: 238, A: 1.0 // gray07
    public static let gray3 =  #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.831372549, alpha: 1) // Hex: #D4D4D4, R: 212, G: 212, B: 212, A: 1.0 // gray17
    public static let gray4 =  #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1) // Hex: #888888, R: 136, G: 136, B: 136, A: 1.0 // gray47
    public static let gray5 =  #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1) // Hex: #555555, R: 85, G: 85, B: 85, A: 1.0    // gray67
    public static let gray6 =  #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // Hex: #333333, R: 51, G: 51, B: 51, A: 1.0    // gray80
    
    // MARK: - Gray Alpha
    
    public static let gray1Alpha =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.05) // Hex: #000000, R: 0, G: 0, B: 0, A: 0.05
    public static let gray2Alpha =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1) // Hex: #000000, R: 0, G: 0, B: 0, A: 0.1
    public static let gray3Alpha =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2) // Hex: #000000, R: 0, G: 0, B: 0, A: 0.2
    public static let gray4Alpha =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4) // Hex: #000000, R: 0, G: 0, B: 0, A: 0.4
    public static let gray5Alpha =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6) // Hex: #000000, R: 0, G: 0, B: 0, A: 0.6
    public static let gray6Alpha =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8) // Hex: #000000, R: 0, G: 0, B: 0, A: 0.8
    
    // MARK: - White Alpha
    
    public static let white1Alpha =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.05) // Hex: #FFFFFF, R: 255, G: 255, B: 255, A: 0.05
    public static let white2Alpha =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1) // Hex: #FFFFFF, R: 255, G: 255, B: 255, A: 0.1
    public static let white3Alpha =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2) // Hex: #FFFFFF, R: 255, G: 255, B: 255, A: 0.2
    public static let white4Alpha =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4) // Hex: #FFFFFF, R: 255, G: 255, B: 255, A: 0.4
    public static let white5Alpha =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6) // Hex: #FFFFFF, R: 255, G: 255, B: 255, A: 0.6
    public static let white6Alpha =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8) // Hex: #FFFFFF, R: 255, G: 255, B: 255, A: 0.8
    
    
    public static let gray11 =  #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1) // Hex: #E1E1E1, R: 225, G: 225, B: 225, A: 1.0
    public static let gray35 =  #colorLiteral(red: 0.6509803922, green: 0.6509803922, blue: 0.6509803922, alpha: 1) // Hex: #A6A6A6, R: 166, G: 166, B: 166, A: 1.0
    public static let gray40 =  #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) // Hex: #999999, R: 153, G: 153, B: 153, A: 1.0
    public static let gray56 =  #colorLiteral(red: 0.4352941176, green: 0.4352941176, blue: 0.4352941176, alpha: 1) // Hex: #6F6F6F, R: 111, G: 111, B: 111, A: 1.0
    public static let gray60 =  #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) // Hex: #666666, R: 102, G: 102, B: 102, A: 1.0
    public static let gray61 =  #colorLiteral(red: 0.392, green: 0.392, blue: 0.3921568627, alpha: 1) // Hex: #646464, R: 100, G: 100, B: 100, A: 1.0
    public static let gray72 =  #colorLiteral(red: 0.2784313725, green: 0.2784313725, blue: 0.2784313725, alpha: 1) // Hex: #474747, R:  71, G:  71, B:  71, A: 1.0
    public static let gray90 =  #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) // Hex: #191919, R:  25, G:  25, B:  25, A: 1.0
    
    
    // MARK: - Convenience Inits
    
    public convenience init(red255: UInt8, green255: UInt8, blue255: UInt8, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red255)/255.0, green: CGFloat(green255)/255.0, blue: CGFloat(blue255)/255.0, alpha: alpha)
    }
    
    public convenience init(white255: UInt8, alpha: CGFloat = 1.0) {
        self.init(white:CGFloat(white255)/255.0, alpha: alpha)
    }
    
    public convenience init(hexString: String) {
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
    
    public class func fromRGB(_ rgb: RGB) -> UIColor {
        let rgba = (red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: CGFloat(1))
        return fromRGBA(rgba)
    }
    
    public class func fromRGBA(_ rgba: RGBA) -> UIColor {
        return UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
    
    public func rgbaValue() -> RGBA? {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public func rgbValue() -> RGB? {
        guard let rgba = rgbaValue() else { return nil }
        return (red: rgba.red, green: rgba.green, blue: rgba.blue)
    }
    
    public var hexStringValue: String? {
        guard let colorComponents = cgColor.components,
            let red = colorComponents.safeObject(at: 0),
            let green = colorComponents.safeObject(at: 1),
            let blue = colorComponents.safeObject(at: 2) else { return nil }
        
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
    
    public func color(adjustedBy value: CGFloat) -> UIColor {
        guard let rgba = rgbaValue() else { return self }
        return UIColor(red: rgba.red+value, green: rgba.green+value, blue: rgba.blue+value, alpha: rgba.alpha)
    }
    
    public func color(adjustedBy255Points points: Int16) -> UIColor {
        return color(adjustedBy: CGFloat(points)/255.0)
    }
    
}

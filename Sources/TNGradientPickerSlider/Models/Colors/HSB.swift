//
//  HSB.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 02/06/2023.
//  Original: https://github.com/louisdh/huekit/blob/master/HueKit/Model/HSV.swift
//

import Foundation

struct HSB: Hashable {
    
    /// The relative point of the color value in a rectangular spectrum.
    var point: CGPoint {
        return CGPoint(x: saturation, y: CGFloat(brightness))
    }
    
    /// The hue value in degress (0...360).
    let hue: CGFloat
    
    /// Normalised version of the Hue component (0...1).
    var hueNormalised: CGFloat { hue / 360.0 }
    
    /// The saturation value (0...1).
    let saturation: CGFloat
    
    /// The brightness value (0...1).
    let brightness: CGFloat
    
}

extension HSB {
    
    /// Create an HSB instance with a default white color.
    init() {
        self.init(hue: 0.0, saturation: 0.0, brightness: 1.0)
    }
    
    /// Convert the HSB values to RGB.
    /// - Returns: An RGB instance
    func toRGB() -> RGB {
        let rgb = self.hueToRGB()
        
        let c = brightness * saturation
        let m = brightness - c
        
        return RGB(red: rgb.red * c + m, green: rgb.green * c + m, blue: rgb.blue * c + m)
    }
    
    /// Convert the Hue value to RGB.
    /// - Returns: An RGB instance
    func hueToRGB() -> RGB {
        let hPrime = hue / 60.0
        
        let x = 1.0 - abs(hPrime.truncatingRemainder(dividingBy: 2.0) - 1.0)
        
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        
        if hPrime < 1.0 {
            r = 1
            g = x
            b = 0
        } else if hPrime < 2.0 {
            r = x
            g = 1
            b = 0
        } else if hPrime < 3.0 {
            r = 0
            g = 1
            b = x
        } else if hPrime < 4.0 {
            r = 0
            g = x
            b = 1
        } else if hPrime < 5.0 {
            r = x
            g = 0
            b = 1
        } else {
            r = 1
            g = 0
            b = x
        }
        
        return RGB(red: r, green: g, blue: b)
    }
    
}

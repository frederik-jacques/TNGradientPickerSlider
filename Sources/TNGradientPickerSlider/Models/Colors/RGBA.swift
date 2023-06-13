//
//  RGB.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 31/05/2023.
//

import Foundation

struct RGBA: Hashable {
    
    /// The RGB values
    let rgb: RGB
    
    /// The alpha value (0...1)
    let alpha: CGFloat
    
    /// Creates an RGBA instance with a white color.
    init() {
        rgb = RGB(red: 1.0, green: 1.0, blue: 1.0)
        alpha = 1.0
    }
    
    /// Create a RGBA instance
    /// - Parameters:
    ///   - r: The red channel value (0...1)
    ///   - g: The green channel value (0...1)
    ///   - b: The blue channel value (0...1)
    ///   - a: The alpha channel value (0...1)
    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.alpha = a
        self.rgb = RGB(red: r, green: g, blue: b)
    }
    
}

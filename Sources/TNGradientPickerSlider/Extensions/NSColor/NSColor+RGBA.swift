//
//  NSColor+RGBA.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 02/06/2023.
//

import AppKit

extension NSColor {
        
    /// Create a color based on RGBA values.
    /// - Parameter rgba: The rgba values
    convenience init(rgba: RGBA) {
        self.init(red: rgba.rgb.red, green: rgba.rgb.green, blue: rgba.rgb.blue, alpha: rgba.alpha)
    }
    
    /// Convert a color to RGBA values.
    /// - Returns: An RGBA instance
    func toRGBA() -> RGBA? {
        guard let components = cgColor.components else { return nil }
        
        return RGBA(r: components[0], g: components[1], b: components[2], a: components[3])
    }
    
}

//
//  RGB.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 02/06/2023.
//  Original: https://github.com/louisdh/huekit/blob/master/HueKit/Model/RGB.swift
//

import Foundation

struct RGB: Hashable {
    /// The value for the red channel (0...1)
    let red: CGFloat
    
    /// The value for the green channel (0...1)
    let green: CGFloat
    
    /// The value for the blue channel (0...1)
    let blue: CGFloat
}

extension RGB {
    
    /// Create an RGB instance with a default white color.
    init() {
        self.init(red: 1.0, green: 1.0, blue: 1.0)
    }
    
    /// Convert RGB values to HSB.
    /// - Parameters:
    ///   - preserveHS: Keep the Hue & Saturation values if brightness becomes 0 (which results in black)
    ///   - hue: The hue value
    ///   - saturation: The saturation value
    /// - Returns: An HSB instance.
    func toHSB(preserveHS: Bool, hue: CGFloat = 0, saturation: CGFloat = 0) -> HSB {
        
        var h = hue
        
        var s = saturation
        var brightness: CGFloat = 0
        
        var max = red
        
        if max < green {
            max = green
        }
        
        if max < blue {
            max = blue
        }
        
        var min = red
        
        if min > green {
            min = green
        }
        
        if min > blue {
            min = blue
        }
        
        // Brightness (aka Value)
        
        brightness = max
        
        // Saturation
        var sat: CGFloat = 0.0
        
        if max != 0.0 {
            sat = (max - min) / max
            s = sat
        }
        else {
            sat = 0.0
            
            // Black, so sat is undefined, use 0
            if !preserveHS {
                s = 0.0
            }
        }
        
        // Hue
        var delta: CGFloat = 0
        
        if sat == 0.0 {
            // No color, so hue is undefined, use 0
            if !preserveHS {
                h = 0.0
            }
        }
        else {
            delta = max - min
            
            var updatedHue: CGFloat = 0
            
            if red == max {
                updatedHue = (green - blue) / delta
            } else if green == max {
                updatedHue = 2 + (blue - red) / delta
            } else {
                updatedHue = 4 + (red - green) / delta
            }
            
            updatedHue /= 6.0
            
            if updatedHue < 0.0 {
                updatedHue += 1.0
            }
            
            // 0.0 and 1.0 hues are actually both the same (red)
            if !preserveHS || abs(updatedHue - h) != 1.0 {
                h = updatedHue
            }
        }
        
        return HSB(hue: h * 360, saturation: s, brightness: brightness)
    }
    
}

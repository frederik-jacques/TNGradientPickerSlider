//
//  TNGradientPickerSliderConfiguration.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 06/06/2023.
//

import AppKit

public struct TNGradientPickerSliderConfiguration {
    
    /// The configuration for the track
    public let track: Track
    
    /// The configuratino for the color handle
    public let colorHandle: ColorHandle
    
    /// Returns the default configuration.
    public static func standard() -> TNGradientPickerSliderConfiguration {
        let track = Track(height: 12.0, borderColor: NSColor.black.withAlphaComponent(0.3), borderWidth: 1)
        let colorHandle = ColorHandle(radius: 10.0, innerRadius: 5.0, outerCircleColor: NSColor.white, outerCircleBorderColor: NSColor.black.withAlphaComponent(0.3), outerCircleBorderWidth: 1.0, innerCircleBorderColor: NSColor.black.withAlphaComponent(0.3), innerCircleBorderWidth: 1.0)
        
        let config = TNGradientPickerSliderConfiguration(track: track, colorHandle: colorHandle)
                
        return config
    }
    
}

extension TNGradientPickerSliderConfiguration {
    
    public struct Track {
        /// The height for the track
        public let height: CGFloat
        
        /// The border color for the track
        public let borderColor: NSColor
        
        /// The border width for the track
        public let borderWidth: CGFloat
    }
    
}

extension TNGradientPickerSliderConfiguration {
    
    public struct ColorHandle {
        /// The radius of the color handle
        public let radius: CGFloat
        
        /// The radius of the inner circle
        public let innerRadius: CGFloat
        
        /// The background color for the outer circle
        public let outerCircleColor: NSColor
        
        /// The border color for the outer circle
        public let outerCircleBorderColor: NSColor
        
        /// The border width for the outer circle
        public let outerCircleBorderWidth: CGFloat
        
        /// The background color for the inner circle
        public let innerCircleBorderColor: NSColor
        
        /// The border width for the inner circle
        public let innerCircleBorderWidth: CGFloat
        
        /// Convenience property to get the size of the color handle
        public var size: CGSize { CGSize(width: radius * 2, height: radius * 2) }
        
        /// Convenience property to get the size of the inner circle
        public var innerSize: CGSize { CGSize(width: innerRadius * 2, height: innerRadius * 2) }
    }
    
}

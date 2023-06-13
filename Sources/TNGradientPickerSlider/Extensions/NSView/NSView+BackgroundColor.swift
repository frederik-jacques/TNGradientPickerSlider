//
//  NSView+BackgroundColor.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 04/06/2023.
//

import AppKit

extension NSView {
    
    /// Set the background color of the view
    /// - Parameter backgroundColor: The color
    func addBackgroundColor(_ backgroundColor: NSColor) {
        wantsLayer = true
        layer?.backgroundColor = backgroundColor.cgColor
    }
    
}

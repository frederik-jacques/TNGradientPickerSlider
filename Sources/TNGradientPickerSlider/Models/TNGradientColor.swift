//
//  TNGradientColor.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 06/06/2023.
//

import AppKit

final public class TNGradientColor: Equatable {
    
    public enum State {
        case idle
        case selected
        case pickingColor
    }
    
    /// A unique identifier for this color
    public let id: String
    
    /// The current state
    private(set) var state: State = .idle
    
    /// The location where the gradient is position (0...1)
    public var location: CGFloat
    
    /// The color to be shown
    public var color: NSColor
    
    /// Callback when the color has changed
    public var onColorDidChange: ((NSColor) -> Void)?
    
    /// Callback when the state has changed
    public var onStateDidChange: ((State) -> Void)?
    
    public init(id: String = UUID().uuidString, location: CGFloat, color: NSColor) {
        self.id = id
        self.location = location
        self.color = color
    }
    
    public static func ==(lhs: TNGradientColor, rhs: TNGradientColor) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func update(color: NSColor) {
        self.color = color
        onColorDidChange?(color)
    }
    
    public func update(state: State) {
        self.state = state
        onStateDidChange?(state)
    }
    
}

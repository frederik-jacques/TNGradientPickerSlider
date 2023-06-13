//
//  TNSaturationBrightnessView.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 30/05/2023.
//

import Cocoa

final class TNSaturationBrightnessView: NSView {
    
    // MARK: - Properties
    /// The datasource to retrieve color information.
    weak var dataSource: TNColorPickerDataSource?
    
    /// Called when the user changes the saturation/brightness from within this view.
    var onValueDidChange: ((_ saturation: CGFloat, _ brightness: CGFloat) -> Void)?
    
    private var colorIndicator: TNSliderHandleView!
    private var hsb: HSB {
        if let hsb = dataSource?.viewWantsColorInformation().rgb.toHSB(preserveHS: true) {
            return hsb
        }
        else {
            return HSB()
        }
    }
    
    // MARK: - Lifecycle methods
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        drawSaturationBrightnessGradient(context: context, rect: dirtyRect)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        handleMouseEvent(event)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        handleMouseEvent(event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        handleMouseEvent(event)
    }
    
    // MARK: - Public methods
    func refresh() {
        // Redraw the gradient
        setNeedsDisplay(bounds)
        
        // Update the location of the indicator
        let locationX = hsb.point.x * bounds.width
        let locationY = hsb.point.y * bounds.height
        let indicatorPosition = NSPoint(x: locationX, y: locationY)
        
        colorIndicator.update(position: indicatorPosition)
    }
    
    // MARK: - Private methods
    private func setupViews() {
        wantsLayer = true
        layer?.masksToBounds = false
        
        colorIndicator = TNSliderHandleView()
        addSubview(colorIndicator)
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        let position = getNormalizedMousePosition(event: event)
        
        // Calculate the color based on the Hue, Saturation & Brightness values.
        // Saturation is the x-axis
        let saturation = Double(position.x) / Double(bounds.width)
        
        // Brightness is the y-axis
        let brightness = Double(position.y) / Double(bounds.height)
        
        // Update the position of the color selector
        colorIndicator.update(position: position)
        
        // Let the outside world know the new values
        onValueDidChange?(saturation, brightness)
    }
    
    private func getNormalizedMousePosition(event: NSEvent) -> NSPoint {
        let mousePosition = convert(event.locationInWindow, from: nil)
        
        let clampedX = mousePosition.x.clamped(lowerBound: 0, upperBound: bounds.width)
        let clampedY = mousePosition.y.clamped(lowerBound: 0, upperBound: bounds.height)
        
        return NSPoint(x: clampedX, y: clampedY)
    }
    
    private func drawSaturationBrightnessGradient(context: CGContext, rect: CGRect) {
        let colors = [
            NSColor(hue: hsb.hueNormalised, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor,
            NSColor(hue: hsb.hueNormalised, saturation: 0.0, brightness: 1.0, alpha: 1.0).cgColor
        ] as CFArray
        
        let backgroundColors = [
            NSColor(hue: hsb.hueNormalised, saturation: 0.0, brightness: 0.0, alpha: 0.0).cgColor,
            NSColor(hue: hsb.hueNormalised, saturation: 0.0, brightness: 0.0, alpha: 1.0).cgColor
        ] as CFArray
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let colorGradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil),
              let backgroundGradient = CGGradient(colorsSpace: colorSpace, colors: backgroundColors, locations: nil)
        else { return }
        
        context.saveGState()
        context.addRect(rect)
        context.clip()
        
        context.drawLinearGradient(colorGradient, start: CGPoint(x: rect.maxX, y: rect.maxY), end: CGPoint(x: 0, y: rect.maxY), options: CGGradientDrawingOptions())
        context.drawLinearGradient(backgroundGradient, start: CGPoint(x: 0, y: rect.maxY), end: CGPoint(x: 0, y: 0), options: CGGradientDrawingOptions())
        
        context.restoreGState()
    }
    
}

//
//  ColorPreviewCircleView.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 02/06/2023.
//

import Cocoa

final class TNColorPreviewCircleView: NSView {

    // MARK: - Properties
    override var intrinsicContentSize: NSSize { return NSSize(width: 26.0, height: 26.0) }
    
    /// The datasource to retrieve color information.
    weak var dataSource: TNColorPickerDataSource?
    
    // MARK: - Lifecycle methods
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        createCheckerboardPattern(context: context, rect: dirtyRect)
        createColorCircle(context: context, rect: dirtyRect)        
    }
    
    // MARK: - Public methods
    func refresh() {
        setNeedsDisplay(bounds)
    }
    
    // MARK: - Private methods
    private func createCheckerboardPattern(context: CGContext, rect: CGRect){
        guard let patternSpace = CGColorSpace(patternBaseSpace: nil) else { return }
        
        // Draw the transparancy checker pattern
        let drawPattern: CGPatternDrawPatternCallback = { _, context in
            context.addRect(CGRect(x: 0, y: 0, width: 4, height: 4))
            context.setFillColor(NSColor.lightGray.cgColor)
            context.fillPath()
            
            context.addRect(CGRect(x: 4, y: 4, width: 4, height: 4))
            context.setFillColor(NSColor.lightGray.cgColor)
            context.fillPath()
        }
        
        var callbacks = CGPatternCallbacks(version: 0, drawPattern: drawPattern, releaseInfo: nil)
        
        guard let pattern = CGPattern(
            info: nil,
            bounds: CGRect(x: 0, y: 0, width: 4, height: 4),
            matrix: .identity,
            xStep: 8,
            yStep: 8,
            tiling: .constantSpacing,
            isColored: true,
            callbacks: &callbacks)
        else { return }
        
        context.setFillColorSpace(patternSpace)
        
        var alpha: CGFloat = 1.0
        context.setFillPattern(pattern, colorComponents: &alpha)

        let circlePath = NSBezierPath(ovalIn: rect)
        circlePath.addClip()
        circlePath.fill()
    }
    
    private func createColorCircle(context: CGContext, rect: CGRect) {
        guard let rgba = dataSource?.viewWantsColorInformation() else { return }
        
        let color = NSColor(red: rgba.rgb.red, green: rgba.rgb.green, blue: rgba.rgb.blue, alpha: rgba.alpha)
        
        context.setFillColor(color.cgColor)
        context.setStrokeColor(NSColor.black.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(1)
        context.fillEllipse(in: bounds)
        context.strokeEllipse(in: bounds)
    }
    
}

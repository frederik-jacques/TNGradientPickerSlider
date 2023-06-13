//
//  TNTransparancySliderView.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 01/06/2023.
//

import Cocoa

final class TNTransparancySliderView: NSView {
    
    /// The datasource to retrieve color information.
    weak var dataSource: TNColorPickerDataSource?
    
    /// Called when the user changes the alpha from within this view.
    var onValueDidChange: ((Double) -> Void)?
    
    private var alphaView: TransparancyView!
    private var colorSelectionIndicator: TNSliderHandleView!
    
    private var rgba: RGBA { dataSource?.viewWantsColorInformation() ?? RGBA() }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        wantsLayer = true
        layer?.masksToBounds = false
                
        alphaView = TransparancyView()
        alphaView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(alphaView)
        
        NSLayoutConstraint.activate([
            alphaView.topAnchor.constraint(equalTo: topAnchor),
            alphaView.leadingAnchor.constraint(equalTo: leadingAnchor),
            alphaView.trailingAnchor.constraint(equalTo: trailingAnchor),
            alphaView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        colorSelectionIndicator = TNSliderHandleView()
        let yPosition = -colorSelectionIndicator.radius + bounds.midY
        colorSelectionIndicator.update(yPosition: yPosition)
        addSubview(colorSelectionIndicator)
    }
    
    func refresh() {
        alphaView.update(hue: rgba.rgb.toHSB(preserveHS: true).hueNormalised)
        
        updateIndicatorPosition()
    }
    
    override func mouseDown(with event: NSEvent) {
        // The alpha value goes from 0 to 1, so we just need to calculate the ratio
        // from the x position of the mouse to the width of the slider.
        handleMouseEvent(event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        handleMouseEvent(event)
    }
    
    override func mouseUp(with event: NSEvent) {
        handleMouseEvent(event)
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        let ratio = calculateRatio(event: event)
        onValueDidChange?(ratio)
    }
    
    private func calculateRatio(event: NSEvent) -> CGFloat {
        let mousePosition = convert(event.locationInWindow, from: nil)
        let ratio = mousePosition.x / bounds.width
        
        // Make sure the value stays between 0 and 1
        return ratio.clamped(lowerBound: 0, upperBound: 1)
    }
    
    private func updateIndicatorPosition() {
        let xPosition = (rgba.alpha * bounds.size.width) - colorSelectionIndicator.radius
        colorSelectionIndicator.update(xPosition: xPosition)
    }
    
}

private class TransparancyView: NSView {
    
    private var hue: CGFloat = 1.0 {
        didSet {
            guard hue != oldValue else { return }
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext,
              let patternSpace = CGColorSpace(patternBaseSpace: nil)
        else { return }
    
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
        context.fill(dirtyRect)
                
        let colors = [
            NSColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor,
            NSColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let colorGradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil) else { return }
        
        context.drawLinearGradient(colorGradient, start: CGPoint(x: dirtyRect.maxX, y: dirtyRect.maxY), end: CGPoint(x: 0, y: dirtyRect.maxY), options: CGGradientDrawingOptions())
        
        
        layer?.cornerRadius = bounds.height / 2
        
        layer?.borderColor = NSColor.black.withAlphaComponent(0.3).cgColor
        layer?.borderWidth = 1
    }
    
    func update(hue: CGFloat) {
        self.hue = hue
    }
    
}

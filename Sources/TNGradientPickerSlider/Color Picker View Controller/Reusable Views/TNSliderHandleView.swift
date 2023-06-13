//
//  TNSliderHandleView.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 31/05/2023.
//

import AppKit

final class TNSliderHandleView: NSView {
    
    // MARK: - Properties
    override var intrinsicContentSize: NSSize { NSSize(width: 12.0, height: 12.0) }
    
    var width: CGFloat { intrinsicContentSize.width }
    var height: CGFloat { intrinsicContentSize.height }
    var radius: CGFloat { width / 2 }
    
    private var innerRadius: CGFloat = 6.0
    private var circleLayer: CAShapeLayer!
    
    private var fillColor: NSColor = NSColor.white {
        didSet {
            guard fillColor != oldValue else { return }
            circleLayer.fillColor = fillColor.cgColor
        }
    }
    
    private var borderColor: NSColor = NSColor.black {
        didSet {
            guard borderColor != oldValue else { return }
            circleLayer.strokeColor = borderColor.withAlphaComponent(0.3).cgColor
        }
    }
    
    // MARK: - Lifecycle methods
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no-op") }
    
    // MARK: - Public methods
    func update(fillColor: NSColor) {
        self.fillColor = fillColor
    }
    
    func update(borderColor: NSColor) {
        self.borderColor = borderColor
    }
    
    func update(position: CGPoint) {
        var updatedFrame = frame
        updatedFrame.origin = CGPoint(x: position.x - radius, y: position.y - radius)
        
        self.frame = updatedFrame
    }
    
    func update(yPosition: CGFloat) {
        var updatedFrame = frame
        updatedFrame.origin.y = yPosition
        
        self.frame = updatedFrame
    }
    
    func update(xPosition: CGFloat) {
        var updatedFrame = frame
        updatedFrame.origin.x = xPosition
        
        self.frame = updatedFrame
    }
        
    // MARK: - Private methods
    private func setupView() {
        wantsLayer = true
        
        layer?.masksToBounds = false
                
        let innerCircleOffset = (width - innerRadius) / 2
        
        let outerCircle = NSBezierPath(ovalIn: NSRect(origin: .zero, size: intrinsicContentSize))
        let innerCircle = NSBezierPath(ovalIn: NSRect(x: innerCircleOffset, y: innerCircleOffset, width: innerRadius, height: innerRadius)).reversed
        outerCircle.append(innerCircle)
        
        circleLayer = CAShapeLayer()
        circleLayer.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        circleLayer.position = CGPoint(x: radius, y: radius)
        circleLayer.path = outerCircle.cgPath
        
        circleLayer.fillColor = NSColor.white.cgColor
        
        circleLayer.strokeColor = NSColor.black.withAlphaComponent(0.3).cgColor
        circleLayer.lineWidth = 1
        
        layer?.addSublayer(circleLayer)
    }
    
}

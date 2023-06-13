//
//  TNTrackHandleView.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 04/06/2023.
//

import Cocoa

final class TNTrackHandleView: NSView {
    
    // MARK: - Properties
    let gradientColor: TNGradientColor
    
    override var intrinsicContentSize: NSSize { configuration.size }
    
    private var width: CGFloat { intrinsicContentSize.width }
    private var height: CGFloat { intrinsicContentSize.height }
    private var radius: CGFloat { width / 2 }
            
    private var circleLayer: CAShapeLayer!
    private var innerCircleLayer: CAShapeLayer!
            
    private let configuration: TNGradientPickerSliderConfiguration.ColorHandle
    
    // MARK: - Lifecycle methods
    init(configuration: TNGradientPickerSliderConfiguration.ColorHandle, gradientColor: TNGradientColor, origin: CGPoint) {
        self.configuration = configuration
        self.gradientColor = gradientColor
        
        super.init(frame: CGRect(origin: origin, size: configuration.size))
        
        setupView()
        setupBindings()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no-op") }
    
    // MARK: - Public methods    
    func update(state: TNGradientColor.State) {
        gradientColor.update(state: state)
    }
    
    // MARK: - Private methods
    private func setupBindings() {
        gradientColor.onColorDidChange = { [weak self] color in
            self?.handleColorDidChange(color: color)
        }
        
        gradientColor.onStateDidChange = { [weak self] state in
            self?.handleStateDidChange(state: state)
        }
    }
    
    private func handleColorDidChange(color: NSColor) {
        // Don't add implicit animations when setting the colors / locations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        innerCircleLayer.fillColor = color.cgColor
        circleLayer.shadowColor = color.cgColor
        CATransaction.commit()
    }
    
    private func handleStateDidChange(state: TNGradientColor.State) {
        switch state {
        case .idle:
            deflateInnerCircle()
            removeShadow()
            
        case .selected:
            inflateInnerCircle()
            removeShadow()
            
        case .pickingColor:
            inflateInnerCircle()
            addShadow()
        }
    }
    
    private func inflateInnerCircle() {
        innerCircleLayer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2)
    }
    
    private func deflateInnerCircle() {
        innerCircleLayer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
    }
    
    private func addShadow() {
        circleLayer.shadowColor = gradientColor.color.cgColor
        circleLayer.shadowOffset = NSSize(width: 0.0, height: 0.0)
        circleLayer.shadowRadius = 3.0
        circleLayer.shadowOpacity = 1.0
        
        let shadowSize = CGSize(width: bounds.width - 3, height: bounds.height - 3)
        let shadowOrigin = CGPoint(x: bounds.midX - (shadowSize.width * 0.5), y: bounds.midY - (shadowSize.height * 0.5))
        
        circleLayer.shadowPath = NSBezierPath(ovalIn: NSRect(origin: shadowOrigin, size: shadowSize)).cgPath
    }
    
    private func removeShadow() {
        circleLayer.shadowColor = nil
        circleLayer.shadowOpacity = 0.0
        circleLayer.shadowPath = nil
    }
    
}

// MARK: - View creation
extension TNTrackHandleView {
    
    private func setupView() {
        wantsLayer = true
        layer?.masksToBounds = false
        
        createOuterCircleLayer()
        createInnerCircleLayer()
    }
    
    private func createOuterCircleLayer() {
        let outerCircle = NSBezierPath(ovalIn: NSRect(origin: .zero, size: intrinsicContentSize))
                
        circleLayer = CAShapeLayer()
        circleLayer.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        circleLayer.position = CGPoint(x: radius, y: radius)
        circleLayer.path = outerCircle.cgPath
        
        circleLayer.fillColor = configuration.outerCircleColor.cgColor
        circleLayer.strokeColor = configuration.outerCircleBorderColor.cgColor
        circleLayer.lineWidth = configuration.outerCircleBorderWidth
        layer?.addSublayer(circleLayer)
    }
    
    private func createInnerCircleLayer() {
        let innerCircleOffset = configuration.radius - configuration.innerRadius
        
        innerCircleLayer = CAShapeLayer()
        innerCircleLayer.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        innerCircleLayer.position = CGPoint(x: radius, y: radius)
        innerCircleLayer.path = NSBezierPath(ovalIn: NSRect(x: innerCircleOffset, y: innerCircleOffset, width: configuration.innerSize.width, height: configuration.innerSize.height)).cgPath
        innerCircleLayer.fillColor = gradientColor.color.cgColor
        innerCircleLayer.strokeColor = configuration.innerCircleBorderColor.cgColor
        innerCircleLayer.lineWidth = configuration.innerCircleBorderWidth
        layer?.addSublayer(innerCircleLayer)
    }
    
}

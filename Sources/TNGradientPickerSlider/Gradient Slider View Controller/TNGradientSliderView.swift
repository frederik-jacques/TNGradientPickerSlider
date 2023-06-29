//
//  TNGradientSliderView.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 04/06/2023.
//

import Cocoa

protocol TNGradientTrackViewDelegate: AnyObject {
    func gradientTrackView(_ view: TNGradientSliderView, didUpdate gradientColors: [TNGradientColor])
    func gradientTrackView(_ view: TNGradientSliderView, showColorPicker handleView: TNTrackHandleView)
}

final class TNGradientSliderView: NSView {
    
    /// The sorted list of gradient colors, based on their location
    var sortedGradientColors: [TNGradientColor] {
        return trackHandleViews.map { $0.gradientColor }.sorted(by: { $0.location < $1.location })
    }
    
    /// The delegate that will inform the view controller about changes
    private weak var delegate: TNGradientTrackViewDelegate?
    
    /// The configuration for this view
    private let configuration: TNGradientPickerSliderConfiguration
    
    /// List of  handle views on the track
    private var trackHandleViews: [TNTrackHandleView] = []
    
    /// The track handle that is currently active
    private var currentHandleView: TNTrackHandleView? { trackHandleViews.first(where: { $0.gradientColor.state != .idle }) }
    
    /// The actual rectangle of this view where we draw the track.
    /// This takes the width of the handles + border widths into account so the handles will not be cutoff.
    private var actualRectangle: CGRect {
        let inset = configuration.colorHandle.radius + (configuration.colorHandle.outerCircleBorderWidth * 2)
        return CGRect(x: inset, y: 0, width: bounds.width - (2 * inset), height: bounds.height)
    }
    
    private var isCurrentlyPickingColor: Bool { !trackHandleViews.filter({ $0.gradientColor.state == .pickingColor }).isEmpty }
    
    /// The unsorted list of gradient colors
    private var gradientColors: [TNGradientColor]
    
    /// State variable to keep track if the initial gradient colors have been added to the track
    private var didAddInitialHandleViews: Bool = false
    
    private var transparantPatterLayer: CALayer!
    private var gradientLayer: CAGradientLayer!
    private var gradientMaskLayer: CALayer!
    private var borderLayer: CALayer!
    
    /// Are we currently holding on to a handleView that is ripped off
    private var isOffTrack: Bool = false
    
    // MARK: - Properties
    init(configuration: TNGradientPickerSliderConfiguration, gradientColors: [TNGradientColor], delegate: TNGradientTrackViewDelegate) {
        self.configuration = configuration
        self.gradientColors = gradientColors
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no-op") }
    
    // MARK: - Lifecycle methods
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Do not animate the changes when the view is resized
        CATransaction.begin()
        CATransaction.setDisableActions(true)
                
        let cornerRadius = bounds.height / 2
        
        transparantPatterLayer?.cornerRadius = cornerRadius
        gradientMaskLayer.cornerRadius = cornerRadius
        borderLayer.cornerRadius = cornerRadius
        
        transparantPatterLayer.frame = actualRectangle
        gradientLayer.frame = actualRectangle
        gradientMaskLayer.frame = CGRect(origin: .zero, size: actualRectangle.size)
        borderLayer.frame = actualRectangle
        CATransaction.commit()
        
        // If it's the first time, create the handle views now the view has the correct dimensions
        createHandleViewsIfNeeded()
        
        // If the view is being resized, we need to update the handle views to their new
        // relative origin.
        positionHandleViews()
    }
        
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        guard !isCurrentlyPickingColor else { return }
        
        let mousePosition = convert(event.locationInWindow, from: nil)
        
        // Check if we hit an indicator view that is already on the track
        let handleView = trackHandleViews.first(where: { $0.frame.contains(mousePosition) })
        
        if let handleView {
            // We clicked an already existing indicator view
            
            // Bring it to the top (if the view is already in the view hierarchy, it's just brought forward)
            addSubview(handleView)
            
            // If the user has clicked twice in rapid succession ... show the color picker
            if event.clickCount == 2 {
                // Mark as picking color
                update(state: .pickingColor, for: handleView)
                
                delegate?.gradientTrackView(self, showColorPicker: handleView)
            }
            // If the user clicked only once
            else if event.clickCount == 1 {
                // Select it
                update(state: .selected, for: handleView)
            }            
        }
        else {
            // We did not click on a track handle, so we will insert a new handle at this location
            let ratio = calculateRatio(event: event)
            
            let gradientColor = TNGradientColor(location: ratio, color: NSColor.random())
            createHandleView(gradientColor: gradientColor)
        }
        
        // Inform the outside world that the gradient colors have changed
        delegate?.gradientTrackView(self, didUpdate: sortedGradientColors)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        guard let currentHandleView, !isCurrentlyPickingColor else { return }
        
        let mousePosition = convert(event.locationInWindow, from: nil)
        
        // Check if we are trying to rip the color off
        let mousePositionDistanceFromCenterOfTrack = abs(mousePosition.y - bounds.midY)
        
        // Ripping of colors is only allowed when there are more than 2 colors on the track
        if trackHandleViews.count > 2 && mousePositionDistanceFromCenterOfTrack >= 50 {
            let xPosition: CGFloat = mousePosition.x - (currentHandleView.bounds.width * 0.5)
            let yPosition: CGFloat = mousePosition.y - (currentHandleView.bounds.height * 0.5)
            let position = CGPoint(x: xPosition, y: yPosition)
            
            if !isOffTrack {
                // Animate the handle view to the position of the mouse cursor
                self.isOffTrack = true
                
                NSAnimationContext.runAnimationGroup({ context in
                    context.timingFunction = .easeOutBack
                    context.duration = 0.3
                    context.allowsImplicitAnimation = true
                    
                    currentHandleView.animator().frame = CGRect(origin: position, size: configuration.colorHandle.size)
                })
            }
            else {
                // We are already animated, now just follow the mouse around
                currentHandleView.frame = CGRect(origin: position, size: configuration.colorHandle.size)
            }
        }
        else {
            // Calculate where we currently are on the track
            let ratio = calculateRatio(event: event)
            
            // Clamp the mouse position so we can't actually drag outside the track
            let clampedMousePosition = actualRectangle.origin.x + (ratio * actualRectangle.width) - configuration.colorHandle.radius
            
            // Update the location of the color
            currentHandleView.gradientColor.location = ratio
            
            // Update the frame of the handleView so that it moves along with the mouse
            let xPosition: CGFloat = clampedMousePosition
            let yPosition: CGFloat = -(configuration.colorHandle.size.height - bounds.height) * 0.5
            let position = CGPoint(x: xPosition, y: yPosition)
            
            if isOffTrack {
                // If we are currently of track
                if mousePositionDistanceFromCenterOfTrack < 20 {
                    // And the distance to the track is less than 20,
                    // then we want to snap back on the track
                    self.isOffTrack = false
                    
                    NSAnimationContext.runAnimationGroup({ context in
                        context.timingFunction = .easeOutBack
                        context.duration = 0.2
                        context.allowsImplicitAnimation = true
                        
                        currentHandleView.animator().frame = CGRect(origin: position, size: configuration.colorHandle.size)
                    })
                }
                else {
                    // If we are further away ... just keep following the mouse
                    let xPosition: CGFloat = mousePosition.x - (currentHandleView.bounds.width * 0.5)
                    let yPosition: CGFloat = mousePosition.y - (currentHandleView.bounds.height * 0.5)
                    let position = CGPoint(x: xPosition, y: yPosition)
                    
                    currentHandleView.frame = CGRect(origin: position, size: configuration.colorHandle.size)
                }
            }
            else {
                // We're on track, just follow the mouse
                currentHandleView.frame = CGRect(origin: position, size: configuration.colorHandle.size)
            }
            
            // When we are dragging, we also want the gradient on the track to reflect the changes
            updateTrackGradientColor()
            
            // Inform the outside world that the gradient colors have changed
            delegate?.gradientTrackView(self, didUpdate: sortedGradientColors)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
    
        if isOffTrack {
            // We are off track ... so we want to remove the handle view.
            removeCurrentColor()
        }
        else {
            // Deselect the handle view if we are not picking a color
            if currentHandleView?.gradientColor.state != .pickingColor {
                currentHandleView?.update(state: .idle)
            }
        }
    }
    
    private func removeCurrentColor() {
        guard let currentHandleView else { return }
        
        if let index = trackHandleViews.firstIndex(of: currentHandleView) {
            currentHandleView.removeFromSuperview()
            trackHandleViews.remove(at: index)
        }
        
        // Indicate we're not offtrack anymore
        isOffTrack = false
        
        // Inform the outside world that the colors have changed
        delegate?.gradientTrackView(self, didUpdate: sortedGradientColors)
        
        // Update the gradients on the track
        updateTrackGradientColor()
    }

    // MARK: - Public methods
    func update(gradientColors: [TNGradientColor]) {
        didAddInitialHandleViews = true
        
        // Remove the old track handles
        trackHandleViews.forEach({ $0.removeFromSuperview() })
        trackHandleViews = []
        
        // Save the new gradient colors
        self.gradientColors = gradientColors
        
        // Create the handles
        for gradientColor in self.gradientColors {
            print("§§ Create gradient color \(gradientColor.id)")
            createHandleView(gradientColor: gradientColor, selectOnCreation: false)
        }
    }
    
    func updateTrackGradientColor() {
        // Don't add implicit animations when setting the colors / locations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = sortedGradientColors.map({ $0.color.cgColor })
        gradientLayer.locations = sortedGradientColors.map({ NSNumber(floatLiteral: $0.location) })
        CATransaction.commit()
    }
    
    // MARK: - Private methods
    private func createHandleViewsIfNeeded() {
        guard !didAddInitialHandleViews else { return }
        didAddInitialHandleViews = true
        
        for gradientColor in gradientColors {
            createHandleView(gradientColor: gradientColor, selectOnCreation: false)
        }
    }
    
    private func createHandleView(gradientColor: TNGradientColor, selectOnCreation: Bool = true) {
        // Create the handle view and position it correctly on the view
        let handleView = TNTrackHandleView(configuration: configuration.colorHandle, gradientColor: gradientColor, origin: calculatePosition(gradientColor: gradientColor))
        addSubview(handleView)
        
        // Add it to the list of handles
        trackHandleViews.append(handleView)
        
        // Select the new handle view if needed
        if selectOnCreation {
            update(state: .selected, for: handleView)
        }
        
        // Update the trackbar to reflect the new gradient color
        updateTrackGradientColor()
    }
    
    private func calculatePosition(gradientColor: TNGradientColor) -> CGPoint {
        let xPosition: CGFloat = actualRectangle.origin.x + (gradientColor.location * actualRectangle.width) - configuration.colorHandle.radius
        let yPosition: CGFloat = -(configuration.colorHandle.size.height - bounds.height) * 0.5
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    private func positionHandleViews() {
        for trackHandle in trackHandleViews {
            trackHandle.update(origin: calculatePosition(gradientColor: trackHandle.gradientColor))
        }
        
        // Update the trackbar to reflect the new gradient color
        updateTrackGradientColor()
    }
    
    private func update(state: TNGradientColor.State, for handleView: TNTrackHandleView) {
        for trackHandleView in trackHandleViews {
            let isCurrentHandleView = trackHandleView.gradientColor == handleView.gradientColor
            
            if isCurrentHandleView {
                trackHandleView.update(state: state)
            }
            else {
                trackHandleView.update(state: .idle)
            }
        }
    }
    
    private func calculateRatio(event: NSEvent) -> Double {
        // Take the mouse position and convert it relatively to our view
        let mousePosition = convert(event.locationInWindow, from: nil)
        
        // Now map that mouse position to the frame of the gradient layer (which is insetted)
        let convertedMousePosition = gradientLayer.convert(mousePosition, from: layer)
                
        // Calculate the ratio where we pressed against the width of the track
        let ratio = convertedMousePosition.x / actualRectangle.width
                
        // Make sure the ratio value stays between 0 and 1
        return ratio.clamped(lowerBound: 0, upperBound: 1.0)
    }
    
}

// MARK: - View creation
extension TNGradientSliderView {
    
    private func setupView() {
        wantsLayer = true
        layer?.masksToBounds = false
        
        createTransparantPatternLayer()
        createGradientLayer()
        createBorderLayer()
    }
    
    private func createTransparantPatternLayer() {
        transparantPatterLayer = CALayer()
        
        let patternImage = Bundle.module.image(forResource: NSImage.Name("transparancy-pattern"))
        
        transparantPatterLayer.backgroundColor = NSColor(patternImage: patternImage!).cgColor
        layer?.addSublayer(transparantPatterLayer)
    }
    
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        layer?.addSublayer(gradientLayer)
        
        gradientMaskLayer = CALayer()
        gradientMaskLayer.backgroundColor = NSColor.red.cgColor
        gradientLayer.mask = gradientMaskLayer
    }
    
    private func createBorderLayer() {
        borderLayer = CALayer()
        borderLayer.borderWidth = configuration.track.borderWidth
        borderLayer.borderColor = configuration.track.borderColor.cgColor
        layer?.addSublayer(borderLayer)
    }
    
}


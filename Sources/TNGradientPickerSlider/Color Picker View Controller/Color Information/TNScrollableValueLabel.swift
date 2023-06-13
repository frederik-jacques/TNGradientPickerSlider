//
//  TNScrollableValueLabel.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 02/06/2023.
//

import Cocoa

final class TNScrollableValueLabel: NSTextField {

    // MARK: - Properties
    /// Block that will be called when the mouse is dragged left
    var onDecrease: (() -> Void)?
    
    /// Block that will be called when the mouse is dragged right
    var onIncrease: (() -> Void)?
    
    private var trackingArea: NSTrackingArea?
    private var previousPosition: NSPoint?
    
    // MARK: - Lifecycle methods
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        createTrackingAreaIfNeeded()
        
        if let trackingArea, !trackingAreas.contains(trackingArea) {
            addTrackingArea(trackingArea)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        NSCursor.resizeLeftRight.set()
    }
    
    override func mouseDown(with event: NSEvent) {
        previousPosition = event.locationInWindow
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let previousPosition else { return }
        
        if event.locationInWindow.x < previousPosition.x {
            onDecrease?()
        }
        else {
            onIncrease?()
        }
        
        self.previousPosition = event.locationInWindow
    }
    
    override func mouseUp(with event: NSEvent) {
        previousPosition = nil
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        NSCursor.arrow.set()
    }
    
    // MARK: - Public methods
        
    // MARK: - Private methods
    private func setupView() {
        isEditable = false
        isSelectable = false
                
        drawsBackground = false
        isBordered = false
        
        font = NSFont.systemFont(ofSize: 8)
    }
    
    private func createTrackingAreaIfNeeded() {
        guard trackingArea == nil else { return }
        
        trackingArea = NSTrackingArea(rect: bounds, options: [.inVisibleRect, .activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved], owner: self, userInfo: nil)
    }
    
}

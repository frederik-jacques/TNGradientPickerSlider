//
//  TNInlineNumberTextField.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 01/06/2023.
//

import Cocoa

final class TNInlineNumberTextField: NSTextField {

    // MARK: - Properties
    
    /// Update the value when the scrollwheel is used while hovering over the textfield.
    var scrollWheelUpdatesValue: Bool = true
    
    /// Called when the number changes from within this view.
    var onValueDidChange: ((CGFloat) -> Void)?
    
    // The current value that the textfield is showing.
    private(set) var value: CGFloat = 0.0 {
        didSet {
            let number = NSNumber(floatLiteral: value)
            stringValue = numberFormatter.string(from: number) ?? "0"
        }
    }
    
    private lazy var numberFormatter: TNOnlyNumbersFormatter = {
        let nf = TNOnlyNumbersFormatter()
        return nf
    }()
    
    /// The minimum value that can be entered in this textfield.
    private var minimumValue: CGFloat = 0.0
    
    /// The maximum value that can be entered in this textfield.
    private var maximumValue: CGFloat = 100.0
    
    // MARK: - Lifecycle methods
    init(value: CGFloat = 0.0, minimumValue: CGFloat = 0.0, maximumValue: CGFloat = 100.0) {
        self.value = value
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no-op") }
    
    override func scrollWheel(with event: NSEvent) {
        guard scrollWheelUpdatesValue else { return }
        
        super.scrollWheel(with: event)
        
        var updatedValue = value
        
        if event.deltaY < 0 {
            updatedValue += 1
        }
        
        if event.deltaY > 0 {
            updatedValue -= 1
        }
        
        updatedValue.clamp(lowerBound: minimumValue, upperBound: maximumValue)
    
        self.value = updatedValue
        
        onValueDidChange?(self.value)
    }
    
    // MARK: - Public methods
    func update(minimumValue: CGFloat, maximumValue: CGFloat) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
    }
    
    func update(value: CGFloat, invokeValueDidChanged: Bool = true) {        
        self.value = value.clamped(lowerBound: minimumValue, upperBound: maximumValue)
        
        if invokeValueDidChanged {
            onValueDidChange?(value)
        }
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        guard let value = numberFormatter.number(from: stringValue) else {
            return
        }
        
        update(value: value.doubleValue)
    }
    
    func increment() {
        update(value: value + 1)
    }
    
    func decrement() {
        update(value: value - 1)
    }
    
    // MARK: - Private methods
    private func setupView() {
        alignment = .center
        font = NSFont.systemFont(ofSize: 10.0)
        formatter = numberFormatter
        maximumNumberOfLines = 1
    }
    
}

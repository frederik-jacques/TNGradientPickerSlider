//
//  TNHexNumberTextField.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 02/06/2023.
//

import Cocoa

final class TNHexNumberTextField: NSTextField {

    // MARK: - Properties
    
    /// Called when the user changes the hex value from within this view.
    var onValueDidChange: ((RGBA) -> Void)?
    
    // MARK: - Lifecycle methods
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no-op") }
    
    // MARK: - Public methods
    override func textDidEndEditing(_ notification: Notification) {
        let color = NSColor(hex: stringValue)
        
        guard let rgba = color.toRGBA() else { return }
        onValueDidChange?(rgba)
    }
    
    // MARK: - Private methods
    private func setupView() {
        alignment = .center
        font = NSFont.systemFont(ofSize: 10)
    }
    
}

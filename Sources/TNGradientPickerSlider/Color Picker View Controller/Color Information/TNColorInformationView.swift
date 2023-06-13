//
//  TNColorInformationView.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 02/06/2023.
//

import Cocoa

final class TNColorInformationView: NSView {

    // MARK: - Properties
    weak var dataSource: TNColorPickerDataSource?
    
    /// Called when the user changes one of the textfield values from within this view.
    var onValueChanged: ((RGBA) -> Void)?
    
    private var colorMode: TNColorPickerViewController.ColorMode = .rgb {
        didSet {
            guard colorMode != oldValue else { return }
            
        }
    }
    
    private var hexTextField: TNHexNumberTextField!
    private var hexLabel: NSTextField!
    
    private var componentATextField: TNInlineNumberTextField!
    private var componentALabel: TNScrollableValueLabel!
    
    private var componentBTextField: TNInlineNumberTextField!
    private var componentBLabel: TNScrollableValueLabel!
    
    private var componentCTextField: TNInlineNumberTextField!
    private var componentCLabel: TNScrollableValueLabel!
    
    private var alphaTextField: TNInlineNumberTextField!
    private var alphaLabel: TNScrollableValueLabel!
    
    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    // MARK: - Public methods
    func update(colorMode: TNColorPickerViewController.ColorMode) {
        self.colorMode = colorMode
    }
    
    func refresh() {
        guard let rgba = dataSource?.viewWantsColorInformation() else { return }
        
        let color = NSColor(rgba: rgba)
        
        // Update the hex textfield
        hexTextField.stringValue = "#\(color.toHex() ?? "")"
        
        switch colorMode {
        case .rgb:
            componentATextField.update(value: rgba.rgb.red * 255, invokeValueDidChanged: false)
            componentBTextField.update(value: rgba.rgb.green * 255, invokeValueDidChanged: false)
            componentCTextField.update(value: rgba.rgb.blue * 255, invokeValueDidChanged: false)
            
        case .hsb:
            let hsv = rgba.rgb.toHSB(preserveHS: true)
            
            componentATextField.update(value: hsv.hue, invokeValueDidChanged: false)
            componentBTextField.update(value: hsv.saturation * 100, invokeValueDidChanged: false)
            componentCTextField.update(value: hsv.brightness * 100, invokeValueDidChanged: false)
        }
        
        alphaTextField.update(value: rgba.alpha * 100, invokeValueDidChanged: false)
    }
    
    // MARK: - Private methods
    private func setupView() {
        // Hex + Label
        hexTextField = TNHexNumberTextField()
        addSubview(hexTextField)
        
        hexLabel = NSTextField()
        hexLabel.isEditable = false
        hexLabel.isSelectable = false
        hexLabel.drawsBackground = false
        hexLabel.isBordered = false
        hexLabel.font = NSFont.systemFont(ofSize: 8)
        hexLabel.stringValue = "Hex"
        addSubview(hexLabel)
        
        // Component A + Label
        componentATextField = TNInlineNumberTextField()
        addSubview(componentATextField)
        
        componentALabel = TNScrollableValueLabel()
        addSubview(componentALabel)
        
        // Component B + Label
        componentBTextField = TNInlineNumberTextField()
        addSubview(componentBTextField)
        
        componentBLabel = TNScrollableValueLabel()
        addSubview(componentBLabel)
        
        // Component C + Label
        componentCTextField = TNInlineNumberTextField()
        addSubview(componentCTextField)
        
        componentCLabel = TNScrollableValueLabel()
        addSubview(componentCLabel)
        
        // Alpha + Label
        alphaTextField = TNInlineNumberTextField()
        addSubview(alphaTextField)
        
        alphaLabel = TNScrollableValueLabel()
        alphaLabel.stringValue = "Alpha"
        addSubview(alphaLabel)
        
        hexTextField.nextKeyView = componentATextField
        componentATextField.nextKeyView = componentBTextField
        componentBTextField.nextKeyView = componentCTextField
        componentCTextField.nextKeyView = alphaTextField
        alphaTextField.nextKeyView = hexTextField
        
        setupConstraints()
        setupBindings()
        
        updateLabels()
    }
    
    private func setupBindings() {
        
        hexTextField.onValueDidChange = { [weak self] rgba in
            self?.onValueChanged?(rgba)
        }
        
        componentALabel.onIncrease = { [weak self] in
            self?.componentATextField.increment()
        }
        
        componentALabel.onDecrease = { [weak self] in
            self?.componentATextField.decrement()
        }
        
        componentATextField.onValueDidChange = { [weak self] value in
            self?.createColorFromComponents()
        }
        
        componentBLabel.onIncrease = { [weak self] in
            self?.componentBTextField.increment()
        }
        
        componentBLabel.onDecrease = { [weak self] in
            self?.componentBTextField.decrement()
        }
        
        componentBTextField.onValueDidChange = { [weak self] value in
            self?.createColorFromComponents()
        }
        
        componentCLabel.onIncrease = { [weak self] in
            self?.componentCTextField.increment()
        }
        
        componentCLabel.onDecrease = { [weak self] in
            self?.componentCTextField.decrement()
        }
        
        componentCTextField.onValueDidChange = { [weak self] value in
            self?.createColorFromComponents()
        }
        
        alphaLabel.onIncrease = { [weak self] in
            self?.alphaTextField.increment()
        }
        
        alphaLabel.onDecrease = { [weak self] in
            self?.alphaTextField.decrement()
        }
        
        alphaTextField.onValueDidChange = { [weak self] value in
            self?.createColorFromComponents()
        }
    }
    
    private func createColorFromComponents() {
        switch colorMode {
        case .rgb:
            let r = componentATextField.value / 255.0
            let g = componentBTextField.value / 255.0
            let b = componentCTextField.value / 255.0
            let a = alphaTextField.value / 100.0
            
            let rgba = RGBA(r: r, g: g, b: b, a: a)
            
            onValueChanged?(rgba)
            
        case .hsb:
            let h = componentATextField.value / 360
            let s = componentBTextField.value / 100
            let v = componentCTextField.value / 100
            let a = alphaTextField.value / 100.0
            
            let hsv = HSB(hue: h, saturation: s, brightness: v)
            let rgb = hsv.toRGB()
            
            let rgba = RGBA(r: rgb.red, g: rgb.green, b: rgb.blue, a: a)
            onValueChanged?(rgba)
        }
    }
        
    private func setupConstraints() {
        hexTextField.translatesAutoresizingMaskIntoConstraints = false
        hexLabel.translatesAutoresizingMaskIntoConstraints = false
        
        componentATextField.translatesAutoresizingMaskIntoConstraints = false
        componentALabel.translatesAutoresizingMaskIntoConstraints = false
        
        componentBTextField.translatesAutoresizingMaskIntoConstraints = false
        componentBLabel.translatesAutoresizingMaskIntoConstraints = false
        
        componentCTextField.translatesAutoresizingMaskIntoConstraints = false
        componentCLabel.translatesAutoresizingMaskIntoConstraints = false
        
        alphaTextField.translatesAutoresizingMaskIntoConstraints = false
        alphaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            hexTextField.topAnchor.constraint(equalTo: topAnchor),
            hexTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            hexLabel.topAnchor.constraint(equalTo: hexTextField.bottomAnchor, constant: 4.0),
            hexLabel.centerXAnchor.constraint(equalTo: hexTextField.centerXAnchor),
            hexLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            componentATextField.topAnchor.constraint(equalTo: topAnchor),
            componentATextField.leadingAnchor.constraint(equalTo: hexTextField.trailingAnchor, constant: 4.0),
            componentATextField.widthAnchor.constraint(equalToConstant: 31.0),
            
            componentALabel.topAnchor.constraint(equalTo: hexLabel.topAnchor),
            componentALabel.centerXAnchor.constraint(equalTo: componentATextField.centerXAnchor),
            
            componentBTextField.topAnchor.constraint(equalTo: topAnchor),
            componentBTextField.leadingAnchor.constraint(equalTo: componentATextField.trailingAnchor, constant: 4.0),
            componentBTextField.widthAnchor.constraint(equalTo: componentATextField.widthAnchor, multiplier: 1.0),
            
            componentBLabel.topAnchor.constraint(equalTo: hexLabel.topAnchor),
            componentBLabel.centerXAnchor.constraint(equalTo: componentBTextField.centerXAnchor),
            
            componentCTextField.topAnchor.constraint(equalTo: topAnchor),
            componentCTextField.leadingAnchor.constraint(equalTo: componentBTextField.trailingAnchor, constant: 4.0),
            componentCTextField.widthAnchor.constraint(equalTo: componentBTextField.widthAnchor, multiplier: 1.0),
            
            componentCLabel.topAnchor.constraint(equalTo: hexLabel.topAnchor),
            componentCLabel.centerXAnchor.constraint(equalTo: componentCTextField.centerXAnchor),
            
            alphaTextField.topAnchor.constraint(equalTo: topAnchor),
            alphaTextField.leadingAnchor.constraint(equalTo: componentCTextField.trailingAnchor, constant: 4.0),
            alphaTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4.0),
            alphaTextField.widthAnchor.constraint(equalTo: componentATextField.widthAnchor, multiplier: 1.0),
            
            alphaLabel.topAnchor.constraint(equalTo: hexLabel.topAnchor),
            alphaLabel.centerXAnchor.constraint(equalTo: alphaTextField.centerXAnchor),
        ])
    }
    
    private func updateLabels() {
        switch colorMode {
        case .rgb:
            componentALabel.stringValue = "R"
            componentATextField.update(minimumValue: 0, maximumValue: 255)
            
            componentBLabel.stringValue = "G"
            componentBTextField.update(minimumValue: 0, maximumValue: 255)
            
            componentCLabel.stringValue = "B"
            componentCTextField.update(minimumValue: 0, maximumValue: 255)
            
        case .hsb:
            componentALabel.stringValue = "H"
            componentATextField.update(minimumValue: 0, maximumValue: 360)
            
            componentBLabel.stringValue = "S"
            componentBTextField.update(minimumValue: 0, maximumValue: 100)
            
            componentCLabel.stringValue = "B"
            componentCTextField.update(minimumValue: 0, maximumValue: 100)
        }
    }
    
}

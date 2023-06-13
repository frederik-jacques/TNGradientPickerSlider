//
//  TNHueSliderView.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 31/05/2023.
//

import Cocoa

final class TNHueSliderView: NSView {
    
    // MARK: - Properties
    /// The datasource to retrieve color information.
    weak var dataSource: TNColorPickerDataSource?
    
    private var hue: CGFloat { dataSource?.viewWantsColorInformation().rgb.toHSB(preserveHS: true).hueNormalised ?? 0.0 }
    
    /// Called when the user changes the hue from within this view.
    var onValueDidChange: ((Double) -> Void)?
    
    private var hsbView: HSBView!
    private var colorSelectionIndicator: TNSliderHandleView!
    
    // MARK: - Lifecycle methods
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
        
    func refresh() {
        updateIndicatorPosition()
    }
    
    // MARK: - Public methods
    override func mouseDown(with event: NSEvent) {
        // The hue value goes from 0 to 1, so we just need to calculate the ratio
        // from the x position of the mouse to the width of the slider.
        handleMouseEvent(event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        handleMouseEvent(event)
    }
    
    // MARK: - Private methods
    private func setupView() {
        wantsLayer = true
        layer?.masksToBounds = false
        
        hsbView = HSBView()
        hsbView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hsbView)
        
        NSLayoutConstraint.activate([
            hsbView.topAnchor.constraint(equalTo: topAnchor),
            hsbView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hsbView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hsbView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        colorSelectionIndicator = TNSliderHandleView()
        let yPosition = -colorSelectionIndicator.radius + bounds.midY
        colorSelectionIndicator.update(yPosition: yPosition)
        addSubview(colorSelectionIndicator)
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        let ratio = calculateRatio(event: event)        
        onValueDidChange?(ratio)
    }
    
    private func calculateRatio(event: NSEvent) -> Double {
        let mousePosition = convert(event.locationInWindow, from: nil)
        let ratio = mousePosition.x / bounds.width
        
        // Make sure the value stays between 0 and 1
        return ratio.clamped(lowerBound: 0, upperBound: 1.0)
    }
    
    private func updateIndicatorPosition() {
        let xPosition = (hue * bounds.size.width) - colorSelectionIndicator.radius
        colorSelectionIndicator.update(xPosition: xPosition)
    }
    
}


final class HSBView: NSView {
    
    // MARK: - Properties

    // MARK: - Lifecycle methods
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no-op") }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext,
              let image = createHueImage()
        else { return }
        
        context.draw(image, in: bounds)
        
        layer?.cornerRadius = bounds.height / 2
    }
    
    // MARK: - Public methods

    // MARK: - Private methods
    private func setupView() {
        wantsLayer = true
        
        layer?.borderColor = NSColor.black.withAlphaComponent(0.3).cgColor
        layer?.borderWidth = 1
    }
    
    private func createHueImage() -> CGImage? {
        var hsb: [CGFloat] = [0, 1, 1]
        
        guard let context = createContext(width: 256, height: 1),
              var ptr = context.data?.assumingMemoryBound(to: UInt8.self)
        else { return nil }
        
        for x in 0..<256 {
            hsb[0] = CGFloat(x) / 255.0
            
            let hsvVal = HSB(hue: hsb[0] * 360.0, saturation: hsb[1], brightness: hsb[2])

            let rgb = hsvVal.toRGB()
            
            ptr[0] = UInt8(rgb.blue * 255.0)
            ptr[1] = UInt8(rgb.green * 255.0)
            ptr[2] = UInt8(rgb.red * 255.0)
            
            ptr = ptr.advanced(by: 4)
        }
        
        let image = context.makeImage()
        
        return image
    }
    
    private func createContext(width: Int, height: Int) -> CGContext? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo = CGBitmapInfo(rawValue: CGImageByteOrderInfo.order32Little.rawValue)
        let noneSkipFirst = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
        bitmapInfo.formUnion(noneSkipFirst)
        
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        return context
    }
}

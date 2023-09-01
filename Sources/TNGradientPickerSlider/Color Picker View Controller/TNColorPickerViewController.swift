//
//  TNColorPickerViewController.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 30/05/2023.
//

import Cocoa

public protocol TNColorPickerViewControllerDelegate: AnyObject {
    func colorPickerViewController(_ viewController: TNColorPickerViewController, didUpdate color: NSColor)
}

protocol TNColorPickerDataSource: AnyObject {
    func viewWantsColorInformation() -> RGBA
}

public final class TNColorPickerViewController: NSViewController {

    public enum ColorMode {
        case rgb
        case hsb
    }
    
    public weak var delegate: TNColorPickerViewControllerDelegate?
    
    public var onColorDidChange: ((NSColor) -> Void)?
    
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var saturationBrightnessView: TNSaturationBrightnessView!
    @IBOutlet weak var hueSliderView: TNHueSliderView!
    @IBOutlet weak var transparancySliderView: TNTransparancySliderView!
    @IBOutlet weak var colorInformationView: TNColorInformationView!
    @IBOutlet weak var colorPreviewCircle: TNColorPreviewCircleView!
    
    /// The current selected color mode
    private var colorMode: ColorMode
    
    /// The current selected HSB values.
    private var hsb: HSB
    
    /// The current selected alpha value.
    private var alpha: CGFloat
    
    /// The current selected RGBA values (derived from the `hsb` & `alpha` properties).
    private var rgba: RGBA {        
        let rgb = hsb.toRGB()
        return RGBA(r: rgb.red, g: rgb.green, b: rgb.blue, a: alpha)
    }
        
    public init(colorMode: ColorMode, color: NSColor, delegate: TNColorPickerViewControllerDelegate) {
        self.colorMode = colorMode
        
        // Convert the color we have received to HSB.
        // This will be from now on our source of truth.
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
                
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        self.hsb = HSB(hue: hue * 360, saturation: saturation, brightness: brightness)
        self.alpha = alpha
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: Bundle.module)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("no-op") }
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContainerView()
        setupBindings()
        
        saturationBrightnessView.dataSource = self
        hueSliderView.dataSource = self
        transparancySliderView.dataSource = self
        colorInformationView.dataSource = self
        colorPreviewCircle.dataSource = self
        
        updateAllComponents(informDelegate: false)
    }
    
    private func setupBindings() {
        hueSliderView.onValueDidChange = { [weak self] hue in
            self?.didUpdateHue(hue)
        }
        
        transparancySliderView.onValueDidChange = { [weak self] alpha in
            self?.didUpdateAlpha(alpha)
        }
        
        saturationBrightnessView.onValueDidChange = { [weak self] (saturation, brightness) in
            self?.didUpdateSaturationAndBrightness(saturation: saturation, brightness: brightness)
        }
        
        colorInformationView.onValueChanged = { [weak self] rgba in
            self?.didUpdateColorInformation(rgba)
        }
    }
    
    private func didUpdateHue(_ hue: CGFloat) {
        let updatedHSB = HSB(hue: hue * 360, saturation: hsb.saturation, brightness: hsb.brightness)
        self.hsb = updatedHSB
        
        updateAllComponents()
    }
    
    private func didUpdateSaturationAndBrightness(saturation: CGFloat, brightness: CGFloat) {
        let updatedHSB = HSB(hue: hsb.hue, saturation: saturation, brightness: brightness)
        self.hsb = updatedHSB
        
        updateAllComponents()
    }
    
    private func didUpdateAlpha(_ alpha: CGFloat) {
        self.alpha = alpha
        
        updateAllComponents()
    }
    
    private func didUpdateColorInformation(_ rgba: RGBA) {
        self.hsb = rgba.rgb.toHSB(preserveHS: true)
        self.alpha = rgba.alpha
        
        updateAllComponents()
    }
    
    private func updateAllComponents(informDelegate: Bool = true) {
        hueSliderView.refresh()
        saturationBrightnessView.refresh()
        transparancySliderView.refresh()
        colorInformationView.refresh()
        colorPreviewCircle.refresh()
        
        if informDelegate {
            let color = NSColor(rgba: rgba)
            delegate?.colorPickerViewController(self, didUpdate: color)
            
            onColorDidChange?(color)
        }
    }
    
    private func setupContainerView() {
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 4.0
        containerView.layer?.borderColor = NSColor.black.withAlphaComponent(0.3).cgColor
        containerView.layer?.borderWidth = 1
    }
        
}

extension TNColorPickerViewController: TNColorPickerDataSource {
    
    func viewWantsColorInformation() -> RGBA {
        return rgba
    }
    
}



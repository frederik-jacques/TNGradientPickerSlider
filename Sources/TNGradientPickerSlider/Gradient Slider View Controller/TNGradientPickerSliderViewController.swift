//
//  TNGradientPickerSliderViewController.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 04/06/2023.
//

import Cocoa

public protocol TNGradientSliderViewControllerDelegate: AnyObject {
    func gradientSliderViewController(_ viewController: TNGradientPickerSliderViewController, didUpdate gradientColors: [TNGradientColor])
}

public final class TNGradientPickerSliderViewController: NSViewController {
    
    // MARK: - Properties
    public weak var delegate: TNGradientSliderViewControllerDelegate?

    /// The current colors on the track, sorted by their location (from 0 to 1)
    public var gradientColors: [TNGradientColor] { gradientTrackView.sortedGradientColors }
    
    private let initialGradientColors: [TNGradientColor]
    private var gradientTrackView: TNGradientSliderView!
    
    private var colorPickerPopover: NSPopover?
    private var handleViewPickingColor: TNTrackHandleView?
    
    private let configuration: TNGradientPickerSliderConfiguration
    
    // MARK: - Lifecycle methods
    public init(configuration: TNGradientPickerSliderConfiguration, gradientColors: [TNGradientColor]) {
        self.configuration = configuration
        self.initialGradientColors = gradientColors
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) { fatalError("no-op") }
    
    override public func loadView() {
        // We are not using a XIB, so you'll need to create an empty view yourself.
        self.view = NSView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
            
        setupView()
    }
    
    
    // MARK: - Public methods
    public func update(gradientColors: [TNGradientColor]) {
        gradientTrackView.update(gradientColors: gradientColors)
    }

    // MARK: - Private methods
    private func showColorPicker(on handleView: TNTrackHandleView) {
        // Keep track of which handleview is currently picking the color
        self.handleViewPickingColor = handleView
        
        // Show the gradient picker underneath the handle view (if possible)
        let gradientPickerViewController = TNColorPickerViewController(colorMode: .rgb, color: handleView.gradientColor.color, delegate: self)
        colorPickerPopover = NSPopover()
        colorPickerPopover?.delegate = self
        colorPickerPopover?.behavior = .transient
        colorPickerPopover?.contentViewController = gradientPickerViewController
        colorPickerPopover?.show(relativeTo: handleView.frame, of: view, preferredEdge: .minY)
    }

}

// MARK: - View creation
extension TNGradientPickerSliderViewController {
    
    private func setupView() {
        view.wantsLayer = true
        view.layer?.masksToBounds = false
        
        createTrackView()
    }
    
    private func createTrackView() {
        gradientTrackView = TNGradientSliderView(configuration: configuration, gradientColors: initialGradientColors, delegate: self)
        gradientTrackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientTrackView)
        
        NSLayoutConstraint.activate([
            gradientTrackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientTrackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientTrackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            gradientTrackView.heightAnchor.constraint(equalToConstant: configuration.track.height)
        ])
    }
    
}

// MARK: - TNGradientTrackViewDelegate
extension TNGradientPickerSliderViewController: TNGradientTrackViewDelegate {
    
    func gradientTrackView(_ view: TNGradientSliderView, showColorPicker handleView: TNTrackHandleView) {
        showColorPicker(on: handleView)
    }
    
    func gradientTrackView(_ view: TNGradientSliderView, didUpdate gradientColors: [TNGradientColor]) {
        delegate?.gradientSliderViewController(self, didUpdate: gradientColors)
    }
    
}

// MARK: - TNColorPickerViewControllerDelegate
extension TNGradientPickerSliderViewController: TNColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: TNColorPickerViewController, didUpdate color: NSColor) {
        guard let handleViewPickingColor else { return }
        
        // Update the picked color for the handle view
        handleViewPickingColor.gradientColor.update(color: color)
        
        // Update the gradient on the track
        gradientTrackView.updateTrackGradientColor()
                
        // Let the outside world know that the colors have changed
        delegate?.gradientSliderViewController(self, didUpdate: gradientTrackView.sortedGradientColors)
    }
    
}

// MARK: - NSPopoverDelegate
extension TNGradientPickerSliderViewController: NSPopoverDelegate {
    
    public func popoverDidClose(_ notification: Notification) {        
        handleViewPickingColor?.update(state: .idle)
        
        handleViewPickingColor = nil
        colorPickerPopover = nil
    }
    
}

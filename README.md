<img src="https://the-nerd.be/wp-content/uploads/2023/06/tngradientpickerslider-github.jpg" alt="" />

TNGradientPickerSlider is a ready-to-use AppKit component that let your users select multiple colors to build a gradient for your macOS application.

[![](https://github.com/frederik-jacques/TNGradientPickerSlider/actions/workflows/swift.yml/badge.svg)](https://github.com/frederik-jacques/TNGradientPickerSlider/actions/workflows/swift.yml/badge.svg)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffrederik-jacques%2FTNGradientPickerSlider%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/frederik-jacques/TNGradientPickerSlider)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffrederik-jacques%2FTNGradientPickerSlider%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/frederik-jacques/TNGradientPickerSlider)

## ✨ Features

- Add multiple colors to build your gradient by clicking the track
- Visually see how the gradient on the track while adding colors
- Live color picker
- Remove colors by dragging them of the track
- Track UI + handles can be configured

## Demo video
<video height="480" controls>
	<source src="https://the-nerd.be/wp-content/uploads/2023/06/tngradientpickerslider.mp4" type="video/mp4">
</video>

## Contents

- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
- [Credits](#credits)
- [License](#license)

## Requirements

- macOS 11.0+
- Xcode 13+
- Swift 5.4+

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

> Xcode 11+ is required to build SnapKit using Swift Package Manager.

To integrate TNGradientPickerSlider into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/frederik-jacques/TNGradientPickerSlider.git", .upToNextMajor(from: "1.0.0"))
]
```

### Manually

If you prefer not to use SPM, you can integrate TNGradientPickerSlider into your project manually.

---

## Usage

### Quick Start

It's really simple to use TNGradientPickerSlider, just follow these 4 steps and you're good to go!

1. Add `import TNGradientPickerSlider` at the top of your file
2. Create an array of `TNGradientColor`, which hold the initial colors that you want to show on the track
3. Create an instance of `TNGradientPickerSliderViewController` and add it as a child viewcontroller.
4. Add it to the view hierarchy and setup your AutoLayout constraints.
5. Register some object as the `delegate` of TNGradientPickerSliderViewController. This class will receive the information needed whenever the array of gradient colors changes, so you can update your own UI.

```swift
import TNGradientPickerSlider

override func viewDidLoad() {
    super.viewDidLoad()
    
    // 1. Create an array which hold the initial colors you want to show on the track
    let initialGradientColors = [
        TNGradientColor(location: 0.0, color: NSColor.red),
        TNGradientColor(location: 1.0, color: NSColor.blue)
    ]
    
    // 2. Create the view controller
    let gradientSliderViewController = TNGradientPickerSliderViewController(configuration: TNGradientPickerSliderConfiguration.standard(), gradientColors: initialGradientColors)
    
    // 3. Add it as a child view controller of the current view controller
    addChild(gradientSliderViewController)
    
    // 4. Add it to the view hierarchy + setup the constraints
    view.addSubview(gradientSliderViewController.view)
    
    gradientSliderViewController.view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        gradientSliderViewController.view.widthAnchor.constraint(equalToConstant: 200),
        gradientSliderViewController.view.heightAnchor.constraint(equalToConstant: 28),
        gradientSliderViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        gradientSliderViewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
    
    // 5. Register some object to be the delegate which will receive information when the colors array has changed.
    gradientSliderViewController.delegate = self
}
```

Implement the delegate method, so you can update your own UI with the picked colors.

```
extension ViewController: GradientSliderViewControllerDelegate {

   func gradientSliderViewController(_ viewController: TNGradientPickerSliderViewController, didUpdate gradientColors: [TNGradientColor]) {
    
       demoView.update(gradientColors: gradientColors)    
   }
   
}
```

That's it!

### Configuration
When you create an instance of `TNGradientPickerSliderViewController` you can pass in a `TNGradientPickerSliderConfiguration`.

The `TNGradientPickerSliderConfiguration` struct has a static method `standard()`, which will give you the style as seen in the Demo Video.
You can alter the look of the `track` and the `color handles`.

#### Track
The track is the visual part where you add color handles.

To create a different configuration, create an instance of `TNGradientPickerSliderConfiguration.Track` and fill in the necessary properties.

Available properties:

- height
- borderColor
- borderWidth

#### Color Handle
The Color Handle is view that holds the color information which you add to the track.

To create a different configuration, create an instance of `TNGradientPickerSliderConfiguration.ColorHandle` and fill in the necessary properties.

Available properties:

- radius
- innerRadius
- outerCircleColor
- outerCircleBorderColor
- outerCircleBorderWidth
- innerCircleBorderColor
- innerCircleBorderWidth


## Credits

- Frederik Jacques ([@thenerd_be](https://twitter.com/thenerd_be))
- Louis D'hauwe ([@LouisDhauwe](https://twitter.com/LouisDhauwe)) for the RGB/HSV code

## License

TNGradientPickerSlider is released under the MIT license. See LICENSE for details.

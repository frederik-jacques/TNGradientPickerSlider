//
//  CGFloat+Clamp.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 31/05/2023.
//

import Foundation

extension BinaryInteger {
    func clamped(to range: ClosedRange<Self>) -> Self {
        clamped(lowerBound: range.lowerBound, upperBound: range.upperBound)
    }

    func clamped(lowerBound: Self, upperBound: Self) -> Self {
        var copy = self
        copy.clamp(lowerBound: lowerBound, upperBound: upperBound)
        return copy
    }

    mutating func clamp(to range: ClosedRange<Self>) {
        clamp(lowerBound: range.lowerBound, upperBound: range.upperBound)
    }

    mutating func clamp(lowerBound: Self, upperBound: Self) {
        self = min(upperBound, max(lowerBound, self))
    }
}

extension BinaryFloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        clamped(lowerBound: range.lowerBound, upperBound: range.upperBound)
    }

    func clamped(lowerBound: Self, upperBound: Self) -> Self {
        var copy = self
        copy.clamp(lowerBound: lowerBound, upperBound: upperBound)
        return copy
    }

    mutating func clamp(to range: ClosedRange<Self>) {
        clamp(lowerBound: range.lowerBound, upperBound: range.upperBound)
    }

    mutating func clamp(lowerBound: Self, upperBound: Self) {
        self = min(upperBound, max(lowerBound, self))
    }
}

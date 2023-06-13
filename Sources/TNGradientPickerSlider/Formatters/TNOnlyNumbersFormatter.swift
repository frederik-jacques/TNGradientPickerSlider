//
//  TNOnlyNumbersFormatter.swift
//  TNGradientPickerSlider
//
//  Created by Frederik Jacques on 12/06/2023.
//

import Foundation

final class TNOnlyNumbersFormatter: NumberFormatter {
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard !partialString.isEmpty else { return true}
        
        // Create a characterset that contains all characters except numbers
        let charset = NSCharacterSet(charactersIn: "1234567890.").inverted

        // Check if the string contains a character in our blocklist.
        // If it is nil, it means all characters are numbers.
        return partialString.rangeOfCharacter(from: charset) == nil
    }
    
}

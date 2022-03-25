//
//  Copyright 2021 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import Foundation

extension String {
    
    /// Returns this string after removing any character forbidden in a single path component.
    var sanitizedPathComponent: String {
        // See https://superuser.com/a/358861
        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
            .union(.newlines)
            .union(.illegalCharacters)
            .union(.controlCharacters)

        return components(separatedBy: invalidCharacters)
            .joined(separator: " ")
    }
    
    /// Returns a copy of the string after removing the given `suffix`, when present.
        func removingSuffix(_ suffix: String) -> String {
            guard hasSuffix(suffix) else {
                return self
            }
            return String(dropLast(suffix.count))
        }
    
    /// Replaces multiple whitespaces by a single space.
        func coalescingWhitespaces() -> String {
            replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
        }
}

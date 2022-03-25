//
//  Copyright 2021 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import Foundation
import R2Shared

extension Locator: Codable {
    public init(from decoder: Decoder) throws {
        let json = try decoder.singleValueContainer().decode(String.self)
        try self.init(jsonString: json)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(jsonString)
    }
    
   
}
//extension Locator.Text: StringProtocol {
//    public typealias UTF8View = <#type#>
//
//    public typealias UTF16View = <#type#>
//
//    public typealias UnicodeScalarView = <#type#>
//
//    public var startIndex: String.Index {
//        <#code#>
//    }
//
//    public var endIndex: String.Index {
//        <#code#>
//    }
//
//    public mutating func write(_ string: String) {
//        <#code#>
//    }
//
//    public func write<Target>(to target: inout Target) where Target : TextOutputStream {
//        <#code#>
//    }
//
//    public var description: String {
//        <#code#>
//    }
//
//
//}

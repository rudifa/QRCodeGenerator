//
//  EnumUtil.swift v.0.1.0
//  SwiftUtilBiPIOS
//
//  Created by Rudolf Farkas on 18.03.20.
//  Copyright © 2020 Rudolf Farkas. All rights reserved.
//

import Foundation

// https://stackoverflow.com/questions/51103795/how-to-get-next-case-of-enumi-e-write-a-circulating-method-in-swift-4-2
/// Extension adds a circular iterator to a CaseIterable item, usually an enum
///     enum MyEnum: CaseIterable { case a, b, c }
///     var letter = MyEnum.a
///     letter = letter.next
extension CaseIterable where Self: Equatable {
    var next:  Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

//
//  UIUtilTest.swift v.0.1.3
//  SwiftUtilBiPTests
//
//  Created by Rudolf Farkas on 01.07.19.
//  Copyright © 2019 Rudolf Farkas. All rights reserved.
//

import XCTest

class UIUtilTest: XCTestCase {
    override func setUp() {}
    override func tearDown() {}

    func test_UIColor_from_hex_string() {
        let gold = UIColor(hex: "#ffe700ff")
        XCTAssertEqual(gold.description, "UIExtendedSRGBColorSpace 1 0.905882 0 1")
        let white = UIColor(hex: "#ffffffff")
        XCTAssertEqual(white.description, "UIExtendedSRGBColorSpace 1 1 1 1")
        let black = UIColor(hex: "#000000ff")
        XCTAssertEqual(black.description, "UIExtendedSRGBColorSpace 0 0 0 1")
    }
}

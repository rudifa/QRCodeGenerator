//
//  QRCodeGeneratorTests.swift
//  QRCodeGeneratorTests
//
//  Created by Rudolf Farkas on 20.03.20.
//  Copyright © 2020 Rudolf Farkas. All rights reserved.
//

import XCTest

class QRCodeGeneratorTests: XCTestCase {
    override func setUp() {}

    override func tearDown() {}

    func test_QRCodeGenerator() {
        // create an instance

        var generator = QRCodeGenerator()

        // check default settings

        XCTAssertEqual(generator.qrText, "hello")
        XCTAssertEqual(generator.correctionLevel, QRCodeGenerator.CorrectionLevel.corrPct25)
        XCTAssertEqual(generator.imageSidePt, 0.0)
        XCTAssertEqual(generator.urlEncoded, false)
        XCTAssertEqual(generator.mode, QRCodeGenerator.Mode.blackOnWhite)

        // check images generated with default settings

        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{23, 23\}>$"#)

        // check images generated with modified settings

        generator.qrText = "Hello"
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{23, 23\}>$"#)

        generator.correctionLevel = .corrPct7
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{23, 23\}>$"#)

        generator.imageSidePt = 100.0
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{100, 100\}>$"#)

        generator.urlEncoded = true
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{100, 100\}>$"#)

        generator.mode = .clearOnWhite
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{100, 100\}>$"#)

        // create an instance with modified settings

        let generator2 = QRCodeGenerator(qrText: "Bye", correctionLevel: .corrPct30, imageSidePt: 200.0, urlEncoded: true, mode: .clearOnWhite)

        // check image generated with modified settings
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator2.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{200, 200\}>$"#)
    }
}

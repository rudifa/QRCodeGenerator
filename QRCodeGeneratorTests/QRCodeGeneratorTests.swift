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

    func test_QRCodeGenerator_customUrl() {
        XCTAssertEqual(QRCodeGenerator.customUrl(urlIdentifier: "", message: ""), "://")
        XCTAssertEqual(QRCodeGenerator.customUrl(urlIdentifier: "textreader", message: "hello my friends"), "textreader://hello%20my%20friends")
        XCTAssertEqual(QRCodeGenerator.customUrl(urlIdentifier: "textreader", message: "Accentué"), "textreader://Accentu%C3%A9")
        XCTAssertEqual(QRCodeGenerator.customUrl(urlIdentifier: "textreader", message: "warning \u{1F9A0}"), "textreader://warning%20%F0%9F%A6%A0")
    }

    func test_QRCodeGenerator() {
        // create an instance

        var generator = QRCodeGenerator()

        // check default settings

        XCTAssertEqual(generator.qrText, "hello folks")
        XCTAssertEqual(generator.correctionLevel, QRCodeGenerator.CorrectionLevel.corrPct15)
        XCTAssertEqual(generator.imageSidePt, 250.0)
        XCTAssertEqual(generator.customUrl, false)
        XCTAssertEqual(generator.mode, QRCodeGenerator.Mode.coloredOnClear)

        // check images generated with default settings

        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{250, 250\}>$"#)

        // check images generated with modified settings

        generator.qrText = "Hello"
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{250, 250\}>$"#)

        generator.correctionLevel = .corrPct7
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{250, 250\}>$"#)

        generator.imageSidePt = 100.0
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{100, 100\}>$"#)

        generator.customUrl = true
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{100, 100\}>$"#)

        generator.mode = .clearOnWhite
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{100, 100\}>$"#)

        // create an instance with modified settings

        let generator2 = QRCodeGenerator(qrText: "Bye", correctionLevel: .corrPct30, imageSidePt: 200.0, customUrl: true, mode: .clearOnWhite)

        // check image generated with modified settings
        printClassAndFunc(info: "\(generator.uiImage!.description)")
        xctAssertMatches(generator2.uiImage!.description, #"^<UIImage:0x[0-9a-f]{12} anonymous \{200, 200\}>$"#)
    }
}

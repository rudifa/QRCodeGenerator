//
//  QRCodeGenerator.swift
//  QRCodeGenerator
//
//  Created by Rudolf Farkas on 18.03.20.
//  Copyright © 2020 Rudolf Farkas. All rights reserved.
//

import Foundation
import UIKit

struct QRCodeGenerator {
    enum CorrectionLevel: String, CaseIterable {
        case corrPct7 = "L"
        case corrPct15 = "M"
        case corrPct25 = "Q"
        case corrPct30 = "H"

        var pct: String {
            switch self {
            case .corrPct7: return "7%"
            case .corrPct15: return "15%"
            case .corrPct25: return "25%"
            case .corrPct30: return "30%"
            }
        }
    }

    enum Mode: String, CaseIterable {
        case blackOnWhite
        case whiteOnClear
        case clearOnWhite
    }

    var qrText: String = ""
    var correctionLevel = CorrectionLevel.corrPct25
    var imageSidePt = CGFloat(0.0) // 0.0 => scale == 1.0
    var urlEncoded = false
    var mode = Mode.blackOnWhite

    var qrTextPlainOrUrlEncoded: String {
        switch urlEncoded {
        case false:
            return qrText
        case true:
            if let encoded = qrText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                return encoded
            }
            return "NOT_ENCODED:" + qrText
        }
    }

    var ciImage: CIImage? {
        return ciImage(from: qrTextPlainOrUrlEncoded)
    }

    func uiImage(mode: Mode = .blackOnWhite, sizePt: Int = 0) -> UIImage? {
        if let image = ciImage {
            switch self.mode {
            case .blackOnWhite:
                return UIImage(ciImage: image)
            case .whiteOnClear:
                return whiteOnClear(ciImage: image)
            case .clearOnWhite:
                return clearOnWhite(ciImage: image)
            }
        }
        return nil
    }

    func ciImage(from string: String) -> CIImage? {
        // Core Image Filter Reference says:
        // To create a QR code from a string or URL, convert it to an NSData object using NSISOLatin1StringEncoding.
        if let data = string.data(using: .isoLatin1),
            let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")

            if let ciImage = filter.outputImage {
                let scale = imageSidePt == 0.0 ? CGFloat(1.0) : CGFloat(imageSidePt / ciImage.extent.size.height)
                let transform = CGAffineTransform(scaleX: scale, y: scale)

                return ciImage.transformed(by: transform)
            }
        }
        return nil
    }

    // Convert the black-on-white QR code image to white-on-clear image
    func whiteOnClear(ciImage: CIImage) -> UIImage {
        if let colorInvertFilter = CIFilter(name: "CIColorInvert"),
            let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") {
            colorInvertFilter.setValue(ciImage, forKey: "inputImage")
            if let output1 = colorInvertFilter.outputImage {
                maskToAlphaFilter.setValue(output1, forKey: "inputImage")
                if let output2 = maskToAlphaFilter.outputImage {
                    return UIImage(ciImage: output2)
                }
            }
        }
        return UIImage()
    }

    // Convert the black-on-white QR code image to clear-on-white
    func clearOnWhite(ciImage: CIImage) -> UIImage? {
        if let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") {
            maskToAlphaFilter.setValue(ciImage, forKey: "inputImage")
            if let output2 = maskToAlphaFilter.outputImage {
                return UIImage(ciImage: output2)
            }
        }
        return nil
    }
}

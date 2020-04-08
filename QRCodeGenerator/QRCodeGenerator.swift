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
        case blackOnClear
        case blackOnColored
        case blackOnWhite
        case clearOnBlack
        case clearOnColored
        case clearOnWhite
        case coloredOnBlack
        case coloredOnClear
        case coloredOnWhite
        case whiteOnBlack
        case whiteOnClear
        case whiteOnColored
        // case experimental
    }

    var qrText: String
    var correctionLevel: CorrectionLevel
    var imageSidePt: CGFloat // 0.0 => scale == 1.0
    var urlEncoded: Bool
    var mode: Mode
    var foregroundColor = CIColor(red: 0.206, green: 0.599, blue: 0.860) // skyBlue

    init(qrText: String = "hello",
         correctionLevel: CorrectionLevel = .corrPct25,
         imageSidePt: CGFloat = 0.0,
         urlEncoded: Bool = false,
         mode: Mode = .blackOnWhite) {
        self.qrText = qrText
        self.correctionLevel = correctionLevel
        self.imageSidePt = imageSidePt
        self.urlEncoded = urlEncoded
        self.mode = mode
    }

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

    var uiImage: UIImage? {
        if let inputBlackOnWhite = ciImage(from: qrTextPlainOrUrlEncoded) {
            var output: CIImage?
            switch mode {
            case .blackOnClear: output = invertColor(maskToAlpha(invertColor(inputBlackOnWhite)))
            case .blackOnColored: output = colored(inputBlackOnWhite)
            case .blackOnWhite: output = inputBlackOnWhite
            case .clearOnBlack: output = invertColor(maskToAlpha(inputBlackOnWhite))
            case .clearOnColored: output = colored(maskToAlpha(inputBlackOnWhite))
            case .clearOnWhite: output = maskToAlpha(inputBlackOnWhite)
            case .coloredOnBlack: output = colored(invertColor(inputBlackOnWhite))
            case .coloredOnWhite: output = coloredBackgroundUnder(maskToAlpha(inputBlackOnWhite))
            case .coloredOnClear: output = colored(maskToAlpha(invertColor(inputBlackOnWhite)))
            case .whiteOnBlack: output = invertColor(inputBlackOnWhite)
            case .whiteOnClear: output = maskToAlpha(invertColor(inputBlackOnWhite))
            case .whiteOnColored: output = coloredBackgroundUnder(maskToAlpha(invertColor(inputBlackOnWhite)))
            }
            if let output = output {
                return uiImage(from: output)
            }
            return UIImage()
        }
        return nil
    }

    private func uiImage(from ciImage: CIImage?) -> UIImage? {
        let context = CIContext(options: nil)
        if let ciImage = ciImage,
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    /// Returns blackOnWhite QR code image generated from string
    private func ciImage(from string: String) -> CIImage? {
        // Core Image Filter Reference says:
        // To create a QR code from a string or URL, convert it to an NSData object using NSISOLatin1StringEncoding.
        if let data = string.data(using: .isoLatin1),
            let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")

            if let ciImage = filter.outputImage {
                // resize to the requested size
                let scale = imageSidePt == 0.0 ? CGFloat(1.0) : CGFloat(imageSidePt / ciImage.extent.size.height)
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                return ciImage.transformed(by: transform)
            }
        }
        return nil
    }

    // MARK: filter methods for local needs

    /// Return image where .white was replaced by .foregroundColor
    /// - Parameter ciImage: input
    private func colored(_ ciImage: CIImage?) -> CIImage? {
        return colorMatrixed(ciImage, inputColor: foregroundColor)
    }

    /// Return image where .white was replaced by inputColor
    /// - Parameters:
    ///   - ciImage: input
    ///   - inputColor: as desired
    private func colorMatrixed(_ ciImage: CIImage?, inputColor: CIColor) -> CIImage? {
        if let filter = CIFilter(name: "CIColorMatrix") {
            filter.setDefaults()
            let x = inputColor.red
            let y = inputColor.green
            let z = inputColor.blue
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: x, y: 0, z: 0, w: 0), forKey: "inputRVector")
            filter.setValue(CIVector(x: 0, y: y, z: 0, w: 0), forKey: "inputGVector")
            filter.setValue(CIVector(x: 0, y: 0, z: z, w: 0), forKey: "inputBVector")
            print("colorMatrixed rgb: \(x) \(y) \(z)")
            return filter.outputImage
        }
        return nil
    }

    /// Returns image where a background of .foregroundColor was placed under inputImage
    /// - Parameter inputImage: normally contains .clear areas
    private func coloredBackgroundUnder(_ inputImage: CIImage?) -> CIImage? {
        if let background = constantColorGenerator(inputColor: foregroundColor) {
            if let inputImage = inputImage {
                return additionCompositing(inputImage: inputImage, inputBackgroundImage: background.cropped(to: inputImage.extent))
            }
        }
        return nil
    }

    // MARK: basic filter methods

    // see ha1f/CIFilter+Extension.swift at
    // https://gist.github.com/ha1f/de0e7a23a79444105c4b13e6c0dc7fa1

    // Convert the blackOnWhite QR code image to whiteOnBlack image or inverse
    private func invertColor(_ ciImage: CIImage?) -> CIImage? {
        if let colorInvertFilter = CIFilter(name: "CIColorInvert") {
            colorInvertFilter.setValue(ciImage, forKey: kCIInputImageKey)
            return colorInvertFilter.outputImage
        }
        return nil
    }

    /// Return a uniformly colored image
    /// - Parameter inputColor: as desired
    private func constantColorGenerator(inputColor: CIColor) -> CIImage? {
        guard let filter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        filter.setValue(inputColor, forKey: kCIInputColorKey)
        return filter.outputImage
    }

    /// Returns a composited image
    /// - Parameters:
    ///   - inputImage: on top, normally contains .clear areas
    ///   - inputBackgroundImage: below inputImage
    private func additionCompositing(inputImage: CIImage?, inputBackgroundImage: CIImage?) -> CIImage? {
        if let filter = CIFilter(name: "CIAdditionCompositing") {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            filter.setValue(inputBackgroundImage, forKey: kCIInputBackgroundImageKey)
            return filter.outputImage
        }
        return nil
    }

    // Return an image where .black was replaced by .clear
    /// - Parameter ciImage: source
    private func maskToAlpha(_ ciImage: CIImage?) -> CIImage? {
        if let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") {
            maskToAlphaFilter.setValue(ciImage, forKey: kCIInputImageKey)
            return maskToAlphaFilter.outputImage
        }
        return nil
    }
}

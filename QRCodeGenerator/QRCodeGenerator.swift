//
//  QRCodeGenerator.swift v.0.3.3
//  QRCodeGenerator
//
//  Created by Rudolf Farkas on 18.03.20.
//  Copyright © 2020 Rudolf Farkas. All rights reserved.
//

import Foundation
import UIKit

extension CIImage {
    /// Combines the current image with the given image centered.
    func combined(with image: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
        combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(self, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage!
    }

    func rescaleLogo(to qrSize: CGSize) -> CIImage? {
        let scale = qrSize.width / extent.width / 2.5
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        return transformed(by: transform)
    }
}

struct QRCodeGenerator {
    /// Return custom URL similar to "textreader://Great!%20It%20works!"
    /// - Parameters:
    ///   - urlIdentifier: custom URL identifier for an application
    ///   - message: message for the target application
    /// - Returns: URL prefixed with urlIdentifier and percent-encoded message
    static func customUrl(urlIdentifier: String, message: String) -> String? {
        if let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return "\(urlIdentifier)://\(encodedMessage)"
        }
        return nil
    }

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
    var customUrl: Bool
    var customUrlIdentifier: String
    var correctionLevel: CorrectionLevel
    var imageSidePt: CGFloat // 0.0 => scale == 1.0
    var mode: Mode
    var foregroundColor = CIColor(red: 0.206, green: 0.599, blue: 0.860) // skyBlue
    var logoImage: UIImage?

    init(qrText: String = "hello folks",
         customUrlIdentifier: String = "textreader",
         correctionLevel: CorrectionLevel = .corrPct15,
         imageSidePt: CGFloat = 250.0,
         customUrl: Bool = false,
         mode: Mode = .coloredOnClear,
         foregroundColor: CIColor = CIColor(red: 0.206, green: 0.599, blue: 0.860)) {
        self.qrText = qrText
        self.customUrl = customUrl
        self.customUrlIdentifier = customUrlIdentifier
        self.correctionLevel = correctionLevel
        self.imageSidePt = imageSidePt
        self.mode = mode
        self.foregroundColor = foregroundColor
    }

    var qrTextOrCustomUrl: String? {
        if customUrl {
            return QRCodeGenerator.customUrl(urlIdentifier: customUrlIdentifier, message: qrText)
        } else {
            return qrText
        }
    }

    var uiImage: UIImage? {
        var encoded = qrImage(from: qrTextOrCustomUrl!)
        if let logoImage = self.logoImage {
            if let cgImage = logoImage.cgImage {
                let ciImage = CIImage(cgImage: cgImage)
                if let rescaledLogo = ciImage.rescaleLogo(to: (encoded?.extent.size)!) {
                    encoded = encoded?.combined(with: rescaledLogo)
                }
            }
        }
        let output = colorize(inputBlackOnWhite: encoded)
        return uiImage(from: output)
    }

    /// GENERATE: Returns blackOnWhite QR code image generated from string
    private func qrImage(from string: String) -> CIImage? {
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

    /// COLORIZE
    func colorize(inputBlackOnWhite: CIImage?) -> CIImage? {
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
        return output
    }

    /*
     https://stackoverflow.com/questions/38087255/cicolormatrix-filter-result-is-weird
     Question asked Jun 28 '16 at 22:22 by DanielEdrisian
     I am trying to create a CIFilter which converts the following QR Code [black-on-white] to [colored-on-black, rgb (0.0, 0.82, 0.60]
     What the code does is first invert the normal QR code so that it's black on white,
     then it takes that image and applies a filter "CIColorMatrix" on it.
     The result of the code is this [colored-on-black, rgb (0.55, 0.95, 0.86], which is not the color that I wanted.
     Answered Nov 1 '18 at 14:37 by lenooh
        I had to create a context without a colorspace, to get the color correct:
        ...
        let ciContext = CIContext(options: [CIContextOption.outputColorSpace: NSNull(), CIContextOption.workingColorSpace: NSNull()])
        let cgimg = ciContext.createCGImage(outputs!,from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
     */
    /// CONVERT TO UIImage
    private func uiImage(from ciImage: CIImage?) -> UIImage? {
        let context = CIContext(options: [CIContextOption.outputColorSpace: NSNull(), CIContextOption.workingColorSpace: NSNull()])
        if let ciImage = ciImage,
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
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

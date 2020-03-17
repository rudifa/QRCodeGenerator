//
//  ViewController.swift
//  QRCodeGenerator
//
//  Created by Rudolf Farkas on 23.12.19.
//  Copyright © 2019 Rudolf Farkas. All rights reserved.
//

//  https://www.appcoda.com/qr-code-generator-tutorial
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var qrCodeImageView: UIImageView!
    @IBOutlet var qrCodeButton: UIButton!
    @IBOutlet var slider: UISlider!

    var transform: CGAffineTransform {
        return CGAffineTransform(scaleX: CGFloat(slider.value), y: CGFloat(slider.value))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func performQRButtonAction(_: Any) {
        if qrCodeImageView.image == nil {
            if textField.text == "" {
                return
            }

            textField.resignFirstResponder()

            guard let data = textField.text?.data(using: .isoLatin1) else {
                return
            }

            guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
                return
            }

            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")

            guard let qrCodeImage = filter.outputImage?.transformed(by: transform) else {
                return
            }

            qrCodeButton.setTitle("Clear", for: .normal)

            displayQRCodeImage(image: UIImage(ciImage: qrCodeImage))

        } else {
            qrCodeImageView.image = nil

            qrCodeButton.setTitle("Generate", for: .normal)
        }

        textField.isEnabled.toggle()
        // slider.isHidden = !slider.isHidden
    }

    @IBAction func changeImageScaleSliderAction(_: Any) {
        // redisplay
    }

    func displayQRCodeImage(image: UIImage) {
//        let scaleX = qrCodeImageView.frame.size.width / image.size.width
//        let scaleY = qrCodeImageView.frame.size.height / image.size.height

//        let transformedImage = image.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))

//        imgQRCode.image = UIImage(CIImage: transformedImage)
        qrCodeImageView.image = image
    }
}

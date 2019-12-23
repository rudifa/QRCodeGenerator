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

//    @IBOutlet weak var textField: UITextField!
//
//    @IBOutlet weak var imgQRCode: UIImageView!
//
//    @IBOutlet weak var btnAction: UIButton!
//
//    @IBOutlet weak var slider: UISlider!
//
//
//    var qrcodeImage: CIImage!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    // MARK: IBAction method implementation
//
//    @IBAction func performButtonAction(sender: AnyObject) {
//        if qrcodeImage == nil {
//            if textField.text == "" {
//                return
//            }
//
//            let data = textField.text.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
//
//            let filter = CIFilter(name: "CIQRCodeGenerator")
//
//            filter.setValue(data, forKey: "inputMessage")
//            filter.setValue("Q", forKey: "inputCorrectionLevel")
//
//            qrcodeImage = filter.outputImage
//
//            textField.resignFirstResponder()
//
//            btnAction.setTitle("Clear", for: .normal)
//
//            displayQRCodeImage()
//        }
//        else {
//            imgQRCode.image = nil
//            qrcodeImage = nil
//            btnAction.setTitle("Generate", for: .normal)
//        }
//
//        textField.isEnabled = !textField.isEnabled
//        slider.isHidden = !slider.isHidden
//    }
//
//
//    @IBAction func changeImageViewScale(sender: AnyObject) {
//        imgQRCode.transform = CGAffineTransform(scaleX: CGFloat(slider.value), y: CGFloat(slider.value))
//    }
//
//
//    // MARK: Custom method implementation
//
//    func displayQRCodeImage() {
//        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent().size.width
//        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent().size.height
//
//        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
//
//        imgQRCode.image = UIImage(CIImage: transformedImage)
//    }
//

}


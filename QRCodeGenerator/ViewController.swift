//
//  ViewController.swift
//  QRCodeGenerator
//
//  Created by Rudolf Farkas on 23.12.19.
//  Copyright © 2019 Rudolf Farkas. All rights reserved.
//

import UIKit

// MARK: ViewController

class ViewController: UIViewController, UITextFieldDelegate {
    // ViewController selectors
    enum ColorSelector: String, CaseIterable {
        case black, white, darkGreen, skyBlue, pinkish

        var uiColor: UIColor {
            switch self {
            case .black: return .black
            case .white: return .white
            case .darkGreen: return UIColor(hex: "#216C1CFF")
            case .skyBlue: return UIColor(red: 0.206, green: 0.599, blue: 0.860, alpha: 1.0)
            case .pinkish: return UIColor(hex: "#FF7093FF")
            }
        }
    }

    var backgroundColorSelect = ColorSelector.darkGreen

    enum ExportSelector: String, CaseIterable {
        case printer, photos
    }

    var exportToSelect = ExportSelector.printer

    var generator = QRCodeGenerator(mode: .coloredOnWhite) {
        didSet {
            displayQRImage()
        }
    }

    private lazy var qrCodeImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center // no scaling applied to image
        return view
    }()

    private lazy var textField: UITextField = {
        let view = UITextField()
        view.backgroundColor = .white
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func textFieldDidChange(textField: UITextField) {
        print(textField.text ?? "")
        if let text = textField.text {
            generator.qrText = text
        }
    }

    private lazy var textFieldOverlay: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.backgroundColor = .lightGray
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body) // .systemFont(ofSize: 18)
        label.text = ""
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()

    private lazy var qrCodeScaleSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 300 // preliminary
        slider.minimumValue = 0
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .touchDragInside)
        return slider
    }()

    @objc func sliderValueChanged() {
        printClassAndFunc(info: "value= \(qrCodeScaleSlider.value)")
        generator.imageSidePt = CGFloat(qrCodeScaleSlider.value)
    }

    private lazy var nextModeButton = UIButton.actionButton(title: "", action: nextModeButtonTap)

    @objc func nextModeButtonTap(sender: UIButton?) {
        if sender != nil { generator.mode.increment() }
        printClassAndFunc()
        nextModeButton.setTitle(generator.mode.rawValue, for: .normal)
    }

    private lazy var correctionButton = UIButton.actionButton(title: "", action: correctionButtonTap)

    @objc func correctionButtonTap(sender: UIButton?) {
        if sender != nil { generator.correctionLevel.increment() }
        printClassAndFunc()
        correctionButton.setTitle("\(generator.correctionLevel.rawValue) \(generator.correctionLevel.pct)", for: .normal)
    }

    private lazy var urlEncodedButton = UIButton.actionButton(title: "", action: urlEncodedButtonTap)

    @objc func urlEncodedButtonTap(sender: UIButton?) {
        if sender != nil { generator.customUrl.toggle() }
        textField.isUserInteractionEnabled = !generator.customUrl
        textFieldOverlay.isHidden = !generator.customUrl
        textFieldOverlay.text = generator.qrTextOrCustomUrl
        urlEncodedButton.setTitle(generator.customUrl ? "custom url" : "plain", for: .normal)
    }

    @objc func tempExportButtonTap(start: Bool = false) {
        printClassAndFunc()
    }

    @objc func backgroundColorButtonTap(sender: UIButton?) {
        if sender != nil { backgroundColorSelect.increment() }
        view.backgroundColor = backgroundColorSelect.uiColor
        backgroundColorButton.setTitle(backgroundColorSelect.rawValue, for: .normal)
    }

    @objc func exportToButtonTap(sender: UIButton?) {
        if sender != nil { exportToSelect.increment() }
        exportToButton.setTitle("export to", for: .normal)
        exportNowButton.setTitle(exportToSelect.rawValue, for: .normal)
        printClassAndFunc(info: exportToSelect.rawValue)
    }

    @objc func exportNowButtonTap(sender: UIButton?) {
        if sender != nil {
            switch exportToSelect {
            case .printer:
                printQRImage()
            case .photos:
                saveQRImage()
            }
        }
    }

    private lazy var backgroundColorButton = UIButton.actionButton(title: "", action: backgroundColorButtonTap)
    private lazy var exportToButton = UIButton.actionButton(title: "", action: exportToButtonTap)
    private lazy var exportNowButton = UIButton.actionButton(title: "", action: exportNowButtonTap)
//    private lazy var button3 = UIButton.actionButton(title: "Button3", action: { _ in self.printClassAndFunc(info: "Button3") })

    private lazy var sliderHStack = UIStackView.horizontal(subviews: [qrCodeScaleSlider])

    private lazy var exportControlsHStack = UIStackView.horizontal(subviews: [backgroundColorButton, exportToButton, exportNowButton])

    private lazy var generatorControlsHStack = UIStackView.horizontal(subviews: [correctionButton, urlEncodedButton, nextModeButton])

    private lazy var mainVStack = UIStackView.vertical(subviews: [sliderHStack, generatorControlsHStack, exportControlsHStack])

    @objc func doubleTapped() {
        segueToColorMatrixVC()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        textField.delegate = self

        view.backgroundColor = backgroundColorSelect.uiColor

        view.addSubview(textField)
        textField.addSibling(overlaid: textFieldOverlay)
        view.addSubview(qrCodeImageView)
        view.addSubview(mainVStack)

        layoutSubviews()

        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // now the layout is done
        textField.text = generator.qrText
        generator.imageSidePt = qrCodeImageView.frame.size.width // will fill the view

        generator.logoImage = UIImage(named: "logoSHARE_BN.png")
        qrCodeScaleSlider.maximumValue = Float(generator.imageSidePt)
        qrCodeScaleSlider.value = Float(generator.imageSidePt)

        // initialize the button titles
        backgroundColorButtonTap(sender: nil)
        nextModeButtonTap(sender: nil)
        urlEncodedButtonTap(sender: nil)
        correctionButtonTap(sender: nil)

        exportToButtonTap(sender: nil)
        exportNowButtonTap(sender: nil)
    }

    func layoutSubviews() {
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            qrCodeImageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),

            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 9),
            textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -9),
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            textField.heightAnchor.constraint(equalToConstant: 40),

            qrCodeImageView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, constant: -16),
            qrCodeImageView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),

            mainVStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mainVStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            mainVStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 8),
        ])
    }

    func displayQRImage() {
        if let uiImage = generator.uiImage {
            qrCodeImageView.image = uiImage
            printClassAndFunc(info: "uiImage.size= \(uiImage.size)")
        }
    }

    func printQRImage() {
        if let uiImage = generator.uiImage {
            printImage(uiImage)
            printClassAndFunc(info: "uiImage.size= \(uiImage.size)")
        }
    }

    func saveQRImage() {
        if let uiImage = generator.uiImage {
            writeToPhotoAlbum(image: uiImage)
            printClassAndFunc(info: "uiImage.size= \(uiImage.size)")
        }
    }
}

// MARK: - Printer connection

extension UIViewController {
    /// Present the PrintInteractionController to print the image
    /// - Parameter image: image to print
    func printImage(_ image: UIImage) {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "QRCode"

        print("printInfo=", printInfo.dictionaryRepresentation)
        printController.printInfo = printInfo

        print("image.scale=", image.scale, "image.size=", image.size)

        printController.printingItem = image

        printController.present(animated: true) { _, isPrinted, error in
            if error == nil {
                if isPrinted {
                    print("image is printed")
                } else {
                    print("image is not printed")
                }
            }
        }
    }
}

extension UIViewController {
    // save qrImage to Photos
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your QRCode image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

extension ViewController {
    func segueToColorMatrixVC() {
        performSegue(withIdentifier: "segueToColorMatrixVC", sender: self)
    }

    @IBAction func unwindToViewController(_: UIStoryboardSegue) {
        // let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}

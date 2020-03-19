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
    var generator = QRCodeGenerator() {
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
            displayQRImage()
        }
    }

    private lazy var textFieldOverlay: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.backgroundColor = .lightGray // uncomment for visual debugging
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
        // imageSidePt = CGFloat(qrCodeScaleSlider.value)
        // displayQRImage(mode: mode, correction: correction, imageSidePt: imageSidePt, from: qrTextPlainOrUrlEncoded)
        generator.imageSidePt = CGFloat(qrCodeScaleSlider.value)

        displayQRImage()
    }

    private lazy var nextModeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray // uncomment for visual debugging
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitle("", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
        return button
    }()

    @objc func nextButtonTap(start: Bool = false) {
        if !start {
            generator.mode = generator.mode.next
        }
        printClassAndFunc()
        nextModeButton.setTitle(generator.mode.rawValue, for: .normal)
        displayQRImage()
        // (mode: mode, correction: correction, imageSidePt: imageSidePt, from: qrTextPlainOrUrlEncoded)
    }

    private lazy var correctionButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray // uncomment for visual debugging
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitle("", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(correctionButtonTap), for: .touchUpInside)
        return button
    }()

    @objc func correctionButtonTap(start: Bool = false) {
        if !start {
            generator.correctionLevel = generator.correctionLevel.next
        }
        printClassAndFunc()
        correctionButton.setTitle("\(generator.correctionLevel.rawValue) \(generator.correctionLevel.pct)", for: .normal)
        // displayQRImage(mode: mode, correction: correction, imageSidePt: imageSidePt, from: qrTextPlainOrUrlEncoded)
        displayQRImage()
    }

    private lazy var urlEncodedButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray // uncomment for visual debugging
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitle("", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(urlEncodedButtonTap), for: .touchUpInside)
        return button
    }()

    @objc func urlEncodedButtonTap(start: Bool = false) {
        if !start {
            generator.urlEncoded.toggle()
        }
        printClassAndFunc()
        textField.isUserInteractionEnabled = !generator.urlEncoded
        textFieldOverlay.isHidden = !generator.urlEncoded
        textFieldOverlay.text = generator.qrTextPlainOrUrlEncoded
        urlEncodedButton.setTitle(generator.urlEncoded ? "url encoded" : "plain", for: .normal)
        displayQRImage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        textField.delegate = self

        view.backgroundColor = UIColor(hex: "#244131FF") // 212F3F 244131

        view.addSubview(textField)
        view.addSubview(textFieldOverlay)

        view.addSubview(qrCodeImageView)

        view.addSubview(qrCodeScaleSlider)

        view.addSubview(nextModeButton)
        view.addSubview(correctionButton)
        view.addSubview(urlEncodedButton)

        layoutSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // now the layout is done
        generator.imageSidePt = qrCodeImageView.frame.size.width // will fill the view
        qrCodeScaleSlider.maximumValue = Float(generator.imageSidePt)
        qrCodeScaleSlider.value = Float(generator.imageSidePt)

        nextButtonTap(start: true)
        urlEncodedButtonTap(start: true)
        correctionButtonTap(start: true)
    }

    func layoutSubviews() {
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            qrCodeImageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),

            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 9),
            textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -9),
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            textField.heightAnchor.constraint(equalToConstant: 40),

            textFieldOverlay.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            textFieldOverlay.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            textFieldOverlay.topAnchor.constraint(equalTo: textField.topAnchor),
            textFieldOverlay.bottomAnchor.constraint(equalTo: textField.bottomAnchor),

            qrCodeImageView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, constant: -16),
            qrCodeImageView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),

            correctionButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            correctionButton.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            correctionButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            correctionButton.heightAnchor.constraint(equalToConstant: 40),

            urlEncodedButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            urlEncodedButton.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            urlEncodedButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            urlEncodedButton.heightAnchor.constraint(equalToConstant: 40),

            nextModeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            nextModeButton.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            nextModeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            nextModeButton.heightAnchor.constraint(equalToConstant: 40),

            qrCodeScaleSlider.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            qrCodeScaleSlider.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),
            qrCodeScaleSlider.bottomAnchor.constraint(equalTo: urlEncodedButton.topAnchor, constant: -8),
            qrCodeScaleSlider.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    func displayQRImage() {
        if let uiImage = generator.uiImage() {
            qrCodeImageView.image = uiImage
            printClassAndFunc(info: "uiImage.size= \(uiImage.size)")
        }
    }
}

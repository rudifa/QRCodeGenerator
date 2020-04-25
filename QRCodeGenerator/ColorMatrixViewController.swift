//
//  ColorMatrixViewController.swift
//  QRCodeGenerator
//
//  Created by Rudolf Farkas on 08.04.20.
//  Copyright © 2020 Rudolf Farkas. All rights reserved.
//

import UIKit

class ColorMatrixViewController: UIViewController {
    struct Color {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0

        var ciColor: CIColor {
            return CIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }

    var qrCodeGenerator = QRCodeGenerator()

    var color = Color() {
        didSet {
            updateImages()
        }
    }

    private func updateImages() {
        qrCodeGenerator.foregroundColor = color.ciColor
        qrCodeGenerator.mode = .coloredOnWhite
        baseColorImageView.image = qrCodeGenerator.uiImage
        qrCodeGenerator.mode = .coloredOnClear
        transformedColorImageView.image = qrCodeGenerator.uiImage
    }

    private lazy var baseColorImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center // no scaling applied to image
        return view
    }()

    private lazy var transformedColorImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center // no scaling applied to image
        return view
    }()

    private lazy var redColorSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 1.0
        slider.minimumValue = 0
        slider.value = 0.5
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(redColorSliderValueChanged), for: .touchDragInside)
        return slider
    }()

    private lazy var greenColorSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 1.0
        slider.minimumValue = 0
        slider.value = 0.5
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(greenColorSliderValueChanged), for: .touchDragInside)
        return slider
    }()

    private lazy var blueColorSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 1.0
        slider.minimumValue = 0
        slider.value = 0.5
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(blueColorSliderValueChanged), for: .touchDragInside)
        return slider
    }()

    @objc func redColorSliderValueChanged() {
        printClassAndFunc(info: "value= \(redColorSlider.value)")
        color.red = CGFloat(redColorSlider.value)
    }

    @objc func greenColorSliderValueChanged() {
        printClassAndFunc(info: "value= \(greenColorSlider.value)")
        color.green = CGFloat(greenColorSlider.value)
    }

    @objc func blueColorSliderValueChanged() {
        printClassAndFunc(info: "value= \(blueColorSlider.value)")
        color.blue = CGFloat(blueColorSlider.value)
    }

    private lazy var colorImageHStack = UIStackView.horizontal(subviews: [baseColorImageView, transformedColorImageView])

    private lazy var sliderVStack = UIStackView.vertical(subviews: [redColorSlider, greenColorSlider, blueColorSlider])

    private lazy var mainVStack = UIStackView.vertical(subviews: [colorImageHStack, sliderVStack])

    override func viewDidLoad() {
        super.viewDidLoad()

        colorImageHStack.distribution = .fillEqually

        view.backgroundColor = .gray
        view.addSubview(mainVStack)
        layoutSubviews()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tripleTap))
        tap.numberOfTapsRequired = 3
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrCodeGenerator.imageSidePt = view.frame.size.width * 0.4

        // CIColor(red: 0.206, green: 0.599, blue: 0.860) // skyBlue
        redColorSlider.value = 0.206
        greenColorSlider.value = 0.599
        blueColorSlider.value = 0.860

        color.red = CGFloat(redColorSlider.value)
        color.green = CGFloat(greenColorSlider.value)
        color.blue = CGFloat(blueColorSlider.value)

        updateImages()
    }

    func layoutSubviews() {
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            mainVStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mainVStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            mainVStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 8),
        ])
    }

    @objc func tripleTap() {
        backToViewController()
    }
}

extension ColorMatrixViewController {
    func backToViewController() {
        // let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue

        performSegue(withIdentifier: "unwindToVC", sender: self)
    }
}

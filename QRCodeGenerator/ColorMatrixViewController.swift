//
//  ColorMatrixViewController.swift
//  QRCodeGenerator
//
//  Created by Rudolf Farkas on 08.04.20.
//  Copyright © 2020 Rudolf Farkas. All rights reserved.
//

import UIKit

class ColorMatrixViewController: UIViewController {
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
        slider.maximumValue = 255
        slider.minimumValue = 0
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(redColorSliderValueChanged), for: .touchDragInside)
        return slider
    }()

    private lazy var greenColorSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 255
        slider.minimumValue = 0
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(greenColorSliderValueChanged), for: .touchDragInside)
        return slider
    }()

    private lazy var blueColorSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 255
        slider.minimumValue = 0
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(blueColorSliderValueChanged), for: .touchDragInside)
        return slider
    }()

    @objc func redColorSliderValueChanged() {
        printClassAndFunc(info: "value= \(redColorSlider.value)")
    }

    @objc func greenColorSliderValueChanged() {
        printClassAndFunc(info: "value= \(greenColorSlider.value)")
    }

    @objc func blueColorSliderValueChanged() {
        printClassAndFunc(info: "value= \(blueColorSlider.value)")
    }


    private lazy var colorImageHStack = UIStackView.horizontal(subviews: [baseColorImageView, transformedColorImageView])

    private lazy var sliderVStack = UIStackView.vertical(subviews: [redColorSlider, greenColorSlider, blueColorSlider])

    private lazy var mainVStack = UIStackView.vertical(subviews: [colorImageHStack, sliderVStack])

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(mainVStack)
        layoutSubviews()

        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }

    func layoutSubviews() {
         let safeAreaLayoutGuide = view.safeAreaLayoutGuide

         NSLayoutConstraint.activate([
             mainVStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
             mainVStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
             mainVStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 8),
         ])
     }

    @objc func doubleTapped() {
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

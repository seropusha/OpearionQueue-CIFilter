//
//  ViewController.swift
//  OperationQueue+CIFilter
//
//  Created by Sergey Navka on 7/5/19.
//  Copyright © 2019 Sergey Navka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var brightnessSlider: UISlider!
    @IBOutlet private weak var blurSlider: UISlider!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private let operationQueue: OperationQueue = .init()
    private var brightnessFilter: CIFilter = CIFilter(name: "CIColorControls")!
    private var blurFilter: CIFilter = CIFilter(name: "CIBoxBlur")!
    private var context: CIContext = CIContext(options: nil)
    private var originalImage: UIImage {
        return UIImage(named: "nature")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brightnessSlider.isContinuous = false
        blurSlider.isContinuous = false
        brightnessSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        blurSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        imageView.image = originalImage
        operationQueue.qualityOfService = .userInteractive
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        switch sender {
        case brightnessSlider:
            brightnessFilter.setValue(value, forKey: kCIInputBrightnessKey)
        case blurSlider:
            blurFilter.setValue(value, forKey: kCIInputRadiusKey)
        default: break
        }
        let filterOpertaion = ApplyFilterOperation([brightnessFilter, blurFilter],
                                               inputImage: originalImage.cgImage,
                                               context: context) { [weak self] cgImage in
                                                guard let cgImage = cgImage else { return }
                                                let uiImage = UIImage(cgImage: cgImage)
                                                DispatchQueue.main.async {
                                                    self?.imageView.image = uiImage
                                                    self?.activityIndicator.stopAnimating()
                                                }
        }
        activityIndicator.startAnimating()
        operationQueue.cancelAllOperations()
        operationQueue.addOperation(filterOpertaion)
    }
}

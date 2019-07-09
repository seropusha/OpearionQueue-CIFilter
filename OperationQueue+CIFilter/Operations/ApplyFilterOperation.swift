//
//  ApplyFilterOperation.swift
//  OperationQueue+CIFilter
//
//  Created by Sergey Navka on 7/8/19.
//  Copyright © 2019 Sergey Navka. All rights reserved.
//

import CoreGraphics
import CoreImage

class ApplyFilterOperation: Operation {
    let filters: [CIFilter]
    let context: CIContext
    let inputImage: CGImage?
    let completion: (CGImage?) -> ()
    private var _isExecuting: Bool = false
    private var _isFinished: Bool = false
    
    override var isFinished: Bool {
        return _isFinished
    }
    
    override var isExecuting: Bool {
        return _isExecuting
    }
    
    init(_ filters: [CIFilter],
         inputImage: CGImage?,
         context: CIContext,
         completion: @escaping (CGImage?) -> ()) {
        self.filters = filters
        self.context = context
        self.completion = completion
        self.inputImage = inputImage
        super.init()
    }
    
    override func main() {
        if isCancelled { return }
        _isExecuting = true
        guard let inputImage = inputImage else { return }
        var ciImage: CIImage! = CIImage(cgImage: inputImage)
        for filter in filters {
            if isCancelled { return }
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            ciImage = filter.outputImage
        }
        if isCancelled { return }
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        _isExecuting = false
        _isFinished = true
        completion(cgImage)
    }
}

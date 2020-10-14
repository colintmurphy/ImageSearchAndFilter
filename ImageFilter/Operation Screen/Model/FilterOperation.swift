//
//  FilterOperation.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/9/20.
//

import UIKit

class FilterOperation: Operation {
    
    // MARK: - Variables
    
    var filteredImage: UIImage?
    private var image: UIImage
    private let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Override Operation Variables
    
    private var _isFinished = false
    override var isFinished: Bool {
        get {
            return self._isFinished
        }
        set {
            if self._isFinished != newValue {
                willChangeValue(forKey: "isFinished")
                self._isFinished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    // MARK: - Init
    
    init(image: UIImage) {
        self.image = image
    }
    
    // MARK: - Start
    
    override func start() {
        
        if isCancelled { return }
        
        guard let ciImage = self.image.ciImage else { return }
        
        let cacheKey = NSString(string: ciImage.description)
        
        if let image = cache.object(forKey: cacheKey) {
            self.filteredImage = image
            return
        }
        
        if let filterImage = self.setFilter(ciImage, filterType: CIFilterType.blackWhite) {
            let image = UIImage(ciImage: filterImage)
            self.filteredImage = image
            self.cache.setObject(image, forKey: cacheKey)
            self.isFinished = true
        }
    }
    
    // MARK: - Filter Method
    
    private func setFilter(_ input: CIImage, filterType: CIFilterType) -> CIImage? {
        
        let filter = CIFilter(name: filterType.rawValue)
        filter?.setValue(input, forKey: kCIInputImageKey)
        
        switch filterType {
        case .blackWhite:
            filter?.setValue(0.0, forKey: kCIInputSaturationKey)
            filter?.setValue(0.9, forKey: kCIInputContrastKey)
            
        case .sepia, .bloom:
            filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        }
        return filter?.outputImage
    }
}

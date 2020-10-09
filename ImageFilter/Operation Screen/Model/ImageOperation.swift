//
//  ImageOperation.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/9/20.
//

import UIKit

class ImageOperation: Operation {
    
    // MARK: - Variables
    
    var image: UIImage?
    private let imageUrl: String?
    private let cache = NSCache<NSString, CIImage>()
    
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
    
    init(imageUrl: String?) {
        self.imageUrl = imageUrl
    }
    
    // MARK: - Start
    
    override func main() {
        
        if isCancelled { return }
        
        guard let imageUrlString = self.imageUrl else { return }
        self.downloadImage(with: imageUrlString) { ciImage in
            if let ciImage = ciImage {
                
                self.image = UIImage(ciImage: ciImage)
                self.isFinished = true
            }
        }
    }
    
    // MARK: - Download Image
    
    private func downloadImage(with imageUrl: String, completed: @escaping (CIImage?) -> Void) {
        
        let cacheKey = NSString(string: imageUrl)
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        if let url = URL(string: imageUrl),
            let image = CIImage(contentsOf: url) {
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
            return
        } else {
            completed(nil)
            return
        }
    }
}

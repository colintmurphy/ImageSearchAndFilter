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
        ImageManager.shared.downloadImage(with: imageUrlString) { ciImage in
            if let ciImage = ciImage {
                self.image = UIImage(ciImage: ciImage)
                self.isFinished = true
            }
        }
    }
}

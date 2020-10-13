//
//  ImageManager.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/12/20.
//

import UIKit

class ImageManager {
    
    static let shared = ImageManager()
    
    private let cache = NSCache<NSString, CIImage>()
    
    private init() { }
    
    func downloadImage(with imageUrl: String, completed: @escaping (CIImage?) -> Void) {
        
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

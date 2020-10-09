//
//  ImageProtocol.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/7/20.
//

import Foundation

protocol ImageProtocol: Decodable {
    
    var filter: ImageFilterType { get set }
    var imageUrl: String? { get }
    
    init(dict: [String: Any])
}

struct SplashImageInfo: ImageProtocol {
    
    var filter: ImageFilterType
    var imageUrl: String?

    init(dict: [String: Any]) {
        
        self.filter = .original
        self.imageUrl = dict["url"] as? String
    }
}

struct PexelsImageInfo: ImageProtocol {
    
    var filter: ImageFilterType
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        
        self.filter = .original
        
        if let srcDict = dict["src"] as? [String: Any] {
            self.imageUrl = srcDict["medium"] as? String
        }
    }
}

struct PixabayImageInfo: ImageProtocol {
    
    var filter: ImageFilterType
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        
        self.filter = .original
        self.imageUrl = dict["webformatURL"] as? String
    }
}

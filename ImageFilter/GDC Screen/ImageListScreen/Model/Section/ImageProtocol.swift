//
//  ImageProtocol.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/7/20.
//

import UIKit

protocol ImageProtocol: Decodable {
    
    var filter: FilterType { get set }
    var imageUrl: String? { get }
    var state: DownloadState { get set }
    var currentImage: UIImage? { get set }
    
    init(dict: [String: Any])
}

struct SplashImageInfo: ImageProtocol {
    
    var filter: FilterType
    var imageUrl: String?
    var state: DownloadState
    var currentImage: UIImage?

    init(dict: [String: Any]) {
        
        self.filter = .original
        self.state = .pending
        self.imageUrl = dict["url"] as? String
    }
    
    enum CodingKeys: String, CodingKey {
        
        case filter
        case imageUrl
        case state
    }
}

struct PexelsImageInfo: ImageProtocol {
    
    var filter: FilterType
    var imageUrl: String?
    var state: DownloadState
    var currentImage: UIImage?
    
    init(dict: [String: Any]) {
        
        self.filter = .original
        self.state = .pending
        
        if let srcDict = dict["src"] as? [String: Any] {
            self.imageUrl = srcDict["medium"] as? String
        }
    }
    
    enum CodingKeys: String, CodingKey {
        
        case filter
        case imageUrl
        case state
    }
}

struct PixabayImageInfo: ImageProtocol {
    
    var filter: FilterType
    var imageUrl: String?
    var state: DownloadState
    var currentImage: UIImage?
    
    init(dict: [String: Any]) {
        
        self.filter = .original
        self.state = .pending
        self.imageUrl = dict["webformatURL"] as? String
    }
    
    enum CodingKeys: String, CodingKey {
        
        case filter
        case imageUrl
        case state
    }
}

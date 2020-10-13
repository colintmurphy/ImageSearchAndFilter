//
//  ImageProtocol.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/7/20.
//

import Foundation

protocol ImageProtocol: Decodable {
    
    var filter: FilterType { get set }
    var imageUrl: String? { get }
    var state: DownloadState { get set }
    
    init(dict: [String: Any])
}

struct SplashImageInfo: ImageProtocol {
    
    var filter: FilterType
    var imageUrl: String?
    var state: DownloadState

    init(dict: [String: Any]) {
        
        self.filter = .original
        self.state = .pending
        self.imageUrl = dict["url"] as? String
    }
}

struct PexelsImageInfo: ImageProtocol {
    
    var filter: FilterType
    var imageUrl: String?
    var state: DownloadState
    
    init(dict: [String: Any]) {
        
        self.filter = .original
        self.state = .pending
        
        if let srcDict = dict["src"] as? [String: Any] {
            self.imageUrl = srcDict["medium"] as? String
        }
    }
}

struct PixabayImageInfo: ImageProtocol {
    
    var filter: FilterType
    var imageUrl: String?
    var state: DownloadState
    
    init(dict: [String: Any]) {
        
        self.filter = .original
        self.state = .pending
        self.imageUrl = dict["webformatURL"] as? String
    }
}

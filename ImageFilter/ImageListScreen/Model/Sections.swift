//
//  Sections.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import Foundation

struct Sections {
    
    var provider: Provider
    var dataSource: [ImageProtocol] = []
}

protocol ImageProtocol: Decodable {
    
    var imageUrl: String? { get }
    
    init(dict: [String: Any])
}

struct SplashImageInfo: ImageProtocol {
    
    var imageUrl: String?
    
    //enum CodingKeys: String, CodingKey {
    //    case imageUrl = "url"
    //}

    init(dict: [String: Any]) {
        self.imageUrl = dict["url"] as? String
    }
}

struct PexelsImageInfo: ImageProtocol {
    
    var imageUrl: String?
    
    //enum CodingKeys: String, CodingKey {
    //    case imageUrl = "medium"
    //}
    
    init(dict: [String: Any]) {
        self.imageUrl = dict["medium"] as? String
    }
}

struct PixabayImageInfo: ImageProtocol {
    
    var imageUrl: String?
    
    //enum CodingKeys: String, CodingKey {
    //    case imageUrl = "webformatURL"
    //}
    //
    //enum HitKeys: String, CodingKey {
    //    case hits
    //}
    //
    //init(from decoder: Decoder) throws {
    //    let container = try decoder
    //    container.
    //}
    
    init(dict: [String: Any]) {
        self.imageUrl = dict["webformatURL"] as? String
    }
}
//
//
//
//struct ApiResponse: Decodable {
//
//    //var images: [ResponseImage]?
//    //var hits: [ResponseImage]?
//    var photos: [ResponseImage]?
//}
//
//struct ResponseImage: Decodable {
//
//    //var url: String?
//    //var webformatURL: String?
//    var src: ResponseSourceImage?
//}
//
//struct ResponseSourceImage: Decodable {
//    var small: String?
//}
//

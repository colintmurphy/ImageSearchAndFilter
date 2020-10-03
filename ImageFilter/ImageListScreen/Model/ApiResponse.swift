//
//  ApiResponse.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import Foundation

struct ApiResponse: Decodable {
    
    var images: [ResponseImage]?
    var hits: [ResponseImage]?
    var photos: [ResponseImage]?
}

struct ResponseImage: Decodable {

    var url: String?
    var webformatURL: String?
    var src: ResponseSourceImage?
}

struct ResponseSourceImage: Decodable {
    var small: String?
}

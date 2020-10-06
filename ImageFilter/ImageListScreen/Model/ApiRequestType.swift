//
//  ApiRequestType.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import Foundation

enum ApiRequestType: String {
    
    case splash = "Splash"
    case pexels = "Pexels"
    case pixaBay = "Pixa Bay"
}

enum Splash {
    
    static let name = "Splash"
    static let url = "http://www.splashbase.co/api/v1/images/search?"
    static let parameters = ["query": ""]
}

enum Pexels {
    
    static let name = "Pexels"
    static let url = "https://api.pexels.com/v1/search?"
    static let parameters = ["query": ""]
    static let headers = ["Authorization": "563492ad6f91700001000001d7f7e19ada2d4640964a4f90731831bf"]
}

enum PixaBay {
    
    static let name = "Pixa Bay"
    static let url = "https://pixabay.com/api/?"
    static let parameters = ["key": "18552487-1f1f788770c0bd9185181a8ff", "q": "", "image_type": "photo"]
}

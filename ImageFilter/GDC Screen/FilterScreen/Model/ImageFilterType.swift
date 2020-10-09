//
//  FilterType.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/3/20.
//

import Foundation

enum ImageFilterType: String, Decodable {
    
    case original = "Original"
    case blackWhite = "Black and White"
    case sepia = "Sepia"
    case bloom = "Bloom"
}

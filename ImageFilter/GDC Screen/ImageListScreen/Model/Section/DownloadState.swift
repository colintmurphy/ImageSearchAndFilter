//
//  DownloadState.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/12/20.
//

import Foundation

enum DownloadState: String, Decodable {
    
    case filter
    case original
    case inprogress
    case pending
}

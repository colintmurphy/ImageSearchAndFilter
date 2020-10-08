//
//  Provider.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import Foundation

struct Provider: Hashable {

    var name: String
    var isOn: Bool
    var url: String
    var parameters: [String: String]
    var header: [String: String]?
}

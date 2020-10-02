//
//  Provider.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import Foundation

protocol ProviderDelegate: class {
    func updateProviderIsOn(provider: Provider, isOn: Bool)
}

struct Provider: Hashable {

    var name: String
    var url: String
}

struct ProviderImages: Decodable {
    var images: [ProviderImage]?
}

struct ProviderImage: Decodable {

    var id: Int?
    var url: String?
    var largeUrl: String?
    var sourceId: Int?
    var copyright: String?
    var site: String?

    enum CodingKeys: String, CodingKey {

        case id
        case url
        case largeUrl = "large_url"
        case sourceId = "source_id"
        case copyright
        case site
    }
}

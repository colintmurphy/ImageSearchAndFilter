//
//  MyDelegates.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import Foundation

enum MyDelegates { }

protocol ProviderDelegate: AnyObject {
    func updateProviderIsOn(provider: Provider, isOn: Bool)
}

protocol SwitchDelegate: AnyObject {
    func shouldSwitchChange(provider: Provider, isOn: Bool) -> Bool
}

protocol ImageFilterDelegate: AnyObject {
    func updateImageFilers(with filter: ImageFilterType)
}

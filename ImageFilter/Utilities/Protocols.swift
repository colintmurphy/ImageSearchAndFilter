//
//  Protocols.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import Foundation

protocol ProviderDelegate: class {
    func updateProviderIsOn(provider: Provider, isOn: Bool)
}

protocol SwitchDelegate: class {
    func shouldSwitchChange(provider: Provider, isOn: Bool) -> Bool
}

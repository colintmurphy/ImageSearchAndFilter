//
//  ProviderTableViewCell.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class ProviderTableViewCell: UITableViewCell {

    @IBOutlet private weak var providerLabel: UILabel!
    @IBOutlet private weak var providerSwitch: UISwitch!

    static var reuseId = "ProviderTableViewCell"
    private var provider: Provider?
    
    weak var delegate: ProviderDelegate?
    weak var oneDelegate: OneOnDelegate?

    override func awakeFromNib() {

        super.awakeFromNib()
        self.providerSwitch.addTarget(self, action: #selector(self.switched), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(self.listen), name: NSNotification.Name.init("SwitchStatus"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func set(provider: (provider: Provider, isOn: Bool)) {

        self.provider = provider.provider
        self.providerLabel.text = provider.provider.name
        self.providerSwitch.isOn = provider.isOn
    }
    
    @objc func listen() {
        
    }

    @objc private func switched() {
        
        guard let provider = self.provider else { return }
        
        self.delegate?.updateProviderIsOn(provider: provider, isOn: self.providerSwitch.isOn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.listen), name: NSNotification.Name.init("SwithStatus"), object: nil)
        
        self.oneDelegate?.sendAlert()
        
        /*
        if (self.delegate?.updateProviderIsOn(provider: provider, isOn: self.providerSwitch.isOn)) != nil {
            print()
            
            self.providerSwitch.isOn = true
        }*/
        
        #warning("need to send alert if try to turn the last ON to OFF")
    }
}

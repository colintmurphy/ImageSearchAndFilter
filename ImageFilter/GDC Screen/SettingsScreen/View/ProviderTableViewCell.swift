//
//  ProviderTableViewCell.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class ProviderTableViewCell: UITableViewCell {
    
    // MARK: - @IBOutlets

    @IBOutlet private weak var providerLabel: UILabel!
    @IBOutlet private weak var providerSwitch: UISwitch!
    
    // MARK: - Variables

    static var reuseId = "ProviderTableViewCell"
    private var provider: Provider?
    
    // MARK: - Delegates
    
    weak var delegate: ProviderDelegate?
    weak var switchDelegate: SwitchDelegate?

    // MARK: - Inits
    
    override func awakeFromNib() {

        super.awakeFromNib()
        self.providerSwitch.addTarget(self, action: #selector(self.switched), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Methods

    func set(provider: Provider) {

        self.provider = provider
        self.providerLabel.text = provider.name
        self.providerSwitch.isOn = provider.isOn
    }

    @objc private func switched() {
        
        guard let provider = self.provider,
            let allowSwitch = self.switchDelegate?.shouldSwitchChange(provider: provider, isOn: self.providerSwitch.isOn) else { return }
        
        if allowSwitch {
            self.delegate?.updateProviderIsOn(provider: provider, isOn: self.providerSwitch.isOn)
        } else {
            self.providerSwitch.isOn.toggle()
        }
    }
}

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
    weak var delegate: ProviderDelegate?
    private var provider: Provider?

    override func awakeFromNib() {

        super.awakeFromNib()
        self.providerSwitch.addTarget(self, action: #selector(self.switched), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func set(name: String, isOn: Bool, provider: Provider) {

        self.provider = provider
        self.providerLabel.text = name
        self.providerSwitch.isOn = isOn
    }

    @objc private func switched() {

        guard let provider = self.provider else { return }
        print("switch is: ", self.providerSwitch.isOn)
        self.delegate?.updateProviderIsOn(provider: provider, isOn: self.providerSwitch.isOn)
    }
}

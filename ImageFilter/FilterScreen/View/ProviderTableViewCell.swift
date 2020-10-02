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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func set(name: String, isOn: Bool) {

        self.providerLabel.text = name
        self.providerSwitch.isOn = isOn
    }

    #warning("check when switch changes, and use the delegate here")
}

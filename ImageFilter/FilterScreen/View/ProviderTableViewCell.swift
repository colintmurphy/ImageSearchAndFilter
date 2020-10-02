//
//  ProviderTableViewCell.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class ProviderTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var providerLabel: UILabel!
    
    static var reuseId = "ProviderTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//
//  ImageFilterTableViewCell.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/3/20.
//

import UIKit

class ImageFilterTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var filterNameLabel: UILabel!
    
    static var reuseId = "ImageFilterTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(name: String) {
        self.filterNameLabel.text = name
    }
}

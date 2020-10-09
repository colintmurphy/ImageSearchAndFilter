//
//  FilterTableViewCell.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/3/20.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var filterNameLabel: UILabel!
    
    static var reuseId = "FilterTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(name: String) {
        
        self.filterNameLabel.text = name
        self.accessoryType = .none
    }
}

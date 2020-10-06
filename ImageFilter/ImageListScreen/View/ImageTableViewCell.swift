//
//  ImageTableViewCell.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet private weak var cellImageView: UIImageView!

    static var reuseId = "ImageTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.cellImageView.image = nil
    }

    func setImage(with imageUrl: String, filter: ImageFilterType) {
        
        NetworkManager.shared.downloadFilterImage(with: imageUrl, filter: filter) { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.cellImageView.image = image
                }
            }
        }
    }

    private func setupUI() {
        self.cellImageView.layer.cornerRadius = 10
    }
}

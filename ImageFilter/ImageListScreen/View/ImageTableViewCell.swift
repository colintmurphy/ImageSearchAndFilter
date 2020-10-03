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

    func setImage(with imageUrl: String) {
        
        //self.cellImageView.image = NetworkManager.shared.downloadImage(with: imageUrl)
        
        self.cellImageView.image = nil
        
        NetworkManager.shared.downloadImage(with: imageUrl) { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.cellImageView.image = image
                }
            }
        }

        /*
        guard let url = URL(string: imageUrl) else { return }

        do {
            let data = try Data(contentsOf: url)
            self.cellImageView.image = UIImage(data: data)
        } catch {
            print(error)
        }*/
    }

    private func setupUI() {
        self.cellImageView.layer.cornerRadius = 10
    }
}

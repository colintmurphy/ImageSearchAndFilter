//
//  ImageCollectionViewCell.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    static var reuseId = "ImageCollectionViewCell"
    
    func setImage(with image: UIImage) {
        self.imageView.image = image
    }
}

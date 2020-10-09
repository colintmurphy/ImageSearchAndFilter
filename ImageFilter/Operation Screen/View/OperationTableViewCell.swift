//
//  OperationTableViewCell.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/9/20.
//

import UIKit

class OperationTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var resultImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            self.activityIndicator.hidesWhenStopped = true
        }
    }

    // MARK: - Variables
    
    static let reuseId = "OperationTableViewCell"
    
    // MARK: - Override Methods

    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.resultImageView.image = nil
    }
    
    // MARK: - Update Cell Methods
    
    func setImage(with imageUrl: String?, using queue: OperationQueue) {
        
        guard let imageUrl = imageUrl else { return }
        self.activityIndicator.startAnimating()

        let imageOperation = ImageOperation(imageUrl: imageUrl)
        imageOperation.completionBlock = {
            
            OperationQueue.main.addOperation {
                self.resultImageView.image = imageOperation.image
                guard let operationImage = imageOperation.image else { return }
                let filterOperation = FilterOperation(image: operationImage)
                
                filterOperation.completionBlock = {
                    OperationQueue.main.addOperation {
                        self.activityIndicator.stopAnimating()
                        self.resultImageView.image = filterOperation.filteredImage
                    }
                }
                filterOperation.start()
            }
        }
        queue.addOperation(imageOperation)
    }
    
    private func setupUI() {
        self.resultImageView.layer.cornerRadius = 10
    }
}

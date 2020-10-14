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
    
    func setImage(with imageData: ImageProtocol) {
        
        switch imageData.state {
        case .filter:
            self.activityIndicator.stopAnimating()
            self.resultImageView.image = imageData.currentImage
            
        case .original:
            self.activityIndicator.stopAnimating()
            self.resultImageView.image = imageData.currentImage
            
        case .downloading:
            self.activityIndicator.startAnimating()
            self.resultImageView.image = nil
            
        case .pending:
            self.activityIndicator.stopAnimating()
            self.resultImageView.image = nil
        }
    }
    
    private func setupUI() {
        self.resultImageView.layer.cornerRadius = 10
    }
}

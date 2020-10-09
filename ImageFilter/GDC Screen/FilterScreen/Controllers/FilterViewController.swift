//
//  FilterViewController.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/6/20.
//

import UIKit

class FilterViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var filterTableView: UITableView!
    
    // MARK: - Variables
    
    var image: ImageProtocol?
    var imageIndexPath: IndexPath?
    weak var imageFilterDelegate: ImageFilterDelegate?
    private var imageFilterTypes: [ImageFilterType] = [.original, .blackWhite, .sepia, .bloom]
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupTableView()
    }
    
    // MARK: - Setup

    private func setupTableView() {
        self.filterTableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource

extension FilterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageFilterTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageFilterTableViewCell.reuseId,
                                                       for: indexPath) as? ImageFilterTableViewCell else { fatalError("couldn't create ImageFilterTableViewCell") }
        
        cell.set(name: self.imageFilterTypes[indexPath.row].rawValue)
        
        if let imageFilter = self.image?.filter {
            if imageFilter == self.imageFilterTypes[indexPath.row] {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        image?.filter = self.imageFilterTypes[indexPath.row]
        
        guard let image = self.image,
              let imageIndexPath = self.imageIndexPath else { return }
            
        self.imageFilterDelegate?.updateImageFilter(of: image, at: imageIndexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        self.filterTableView.reloadData()
    }
}

//
//  OperationViewController.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/9/20.
//

import UIKit

class OperationViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.keyboardDismissMode = .onDrag
        }
    }
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            self.searchBar.delegate = self
            self.searchBar.enablesReturnKeyAutomatically = true
        }
    }
    @IBOutlet private weak var noImagesLabel: UILabel! {
        didSet {
            self.noImagesLabel.isHidden = false
        }
    }
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            self.activityIndicator.hidesWhenStopped = true
        }
    }

    // MARK: - Variables
    
    private var timer: Timer?
    private let operationQueue = OperationQueue()
    
    private var _sectionDataSource: [Section] = []
    private var sectionDataSource: [Section] {
        return self._sectionDataSource
    }
    private lazy var providers: [Provider] = {
        return [
            Provider(name: ApiRequestType.splash.rawValue, isOn: true, url: Splash.url, parameters: Splash.parameters),
            Provider(name: ApiRequestType.pexels.rawValue, isOn: true, url: Pexels.url, parameters: Pexels.parameters, headers: Pexels.headers),
            Provider(name: ApiRequestType.pixaBay.rawValue, isOn: true, url: PixaBay.url, parameters: PixaBay.parameters)
        ]
    }()

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setup()
    }

    // MARK: - Setup

    private func setup() {

        self.tableView.isHidden = true
        self.tableView.reloadData()
        self.setupKeyboardHandlers()
    }
    
    // MARK: - Keyboard

    private func setupKeyboardHandlers() {
        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapDismiss.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapDismiss)
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Scroll Helpers
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.operationQueue.cancelAllOperations()
        self.operationQueue.isSuspended = false
        #warning("need to do something else, not just assign isSuspended T/F")
        
        if let visibleIndexes = self.tableView.indexPathsForVisibleRows {
            // see all pending operations here
            // then cancel those pending operations
            // the those operations will be started
            
            // only cancel those that are no longer visible
            self.tableView.reloadRows(at: visibleIndexes, with: .none)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.operationQueue.isSuspended = true
    }
    
    // MARK: - Operations
    
    private func loadImage(withQueryString query: String) {
        
        self.operationQueue.maxConcurrentOperationCount = 2
        
        let notifyOperation = BlockOperation {
            OperationQueue.main.addOperation {
                self.activityIndicator.stopAnimating()
                
                if self.sectionDataSource.isEmpty {
                    self.noImagesLabel.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    self.noImagesLabel.isHidden = true
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            }
        }
        
        self.providers.forEach { provider in
            let operation = JSONOperation(query, provider: provider)
            
            operation.completionBlock = {
                guard let section = operation.section else { return }
                DispatchQueue.global().sync(flags: .barrier) {
                    self._sectionDataSource.append(section)
                }
            }
            notifyOperation.addDependency(operation)
            self.operationQueue.addOperation(operation)
        }
        self.operationQueue.addOperation(notifyOperation)
    }
}

// MARK: - UISearchBarDelegate

extension OperationViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let timer = self.timer {
            timer.invalidate()
            self.operationQueue.cancelAllOperations()
            self.activityIndicator.stopAnimating()
        }
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.count < 5 { return }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(3), repeats: false) { _ in
            self.noImagesLabel.isHidden = true
            self.activityIndicator.startAnimating()
            self._sectionDataSource.removeAll()
            self.loadImage(withQueryString: query)
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension OperationViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionDataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionDataSource[section].dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: OperationTableViewCell.reuseId,
                                                       for: indexPath) as? OperationTableViewCell else { fatalError("couldn't create OperationTableViewCell") }

        // have model set that if filter set yet, that way it'll know if should stop running activity indicator
        
        cell.setImage(with: self.sectionDataSource[indexPath.section].dataSource[indexPath.row].imageUrl, using: self.operationQueue)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension OperationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionDataSource[section].provider.name
    }
}

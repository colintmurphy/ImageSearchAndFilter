//
//  ViewController.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class ImageListViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageTableView: UITableView! {
        didSet {
            imageTableView.keyboardDismissMode = .onDrag
        }
    }
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noImagesLabel: UILabel!

    // MARK: - Variables
    
    var imageFilterOn: ImageFilterType = .original
    private var _sectionDataSource: [Sections] = []
    private var sectionDataSource: [Sections] {
        concurrentQueue.sync {
            return _sectionDataSource
        }
    }
    private var onSections: [Sections] {
        return self.sectionDataSource.filter { $0.provider.isOn }
    }
    
    // MARK: - Dispatches
    
    private let concurrentQueue = DispatchQueue(label: "my.concurrent.queue", attributes: .concurrent)
    private var searchWorkItem: DispatchWorkItem?

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: - Helpers
    
    private func updateParameter(with text: String, _ dict: [String: String]) -> [String: String] {
        
        var parameters = dict
        
        if dict["query"] != nil {
            parameters["query"] = text
        } else if parameters["q"] != nil {
            parameters["q"] = text
        }
        return parameters
    }
    
    private func updatedSection(_ provider: Provider, _ dictionary: Any?) -> [ImageProtocol] {
        
        guard let dictionary = dictionary as? [String: Any] else { return [] }
        var newSection: [ImageProtocol] = []
        
        switch provider.name {
        case Splash.name:
            guard let arrayItems = dictionary["images"] as? [[String: Any]], !arrayItems.isEmpty else { return [] }
            arrayItems.forEach { dictionary in
                newSection.append(SplashImageInfo(dict: dictionary))
            }
            
        case Pexels.name:
            guard let arrayItems = dictionary["photos"] as? [[String: Any]], !arrayItems.isEmpty else { return [] }
            arrayItems.forEach { dictionary in
                newSection.append(PexelsImageInfo(dict: dictionary))
            }
            
        case PixaBay.name:
            guard let arrayItems = dictionary["hits"] as? [[String: Any]], !arrayItems.isEmpty else { return [] }
            arrayItems.forEach { dictionary in
                newSection.append(PixabayImageInfo(dict: dictionary))
            }
            
        default:
            break
        }
        return newSection
    }

    // MARK: - Setup

    private func setup() {

        self.searchBar.delegate = self
        self.createProviders()
        self.setupTable()
        self.setupKeyboardHandlers()
    }

    private func createProviders() {

        let splash = Provider(name: ApiRequestType.splash.rawValue, isOn: true, url: Splash.url, parameters: Splash.parameters)
        let pexels = Provider(name: ApiRequestType.pexels.rawValue, isOn: true, url: Pexels.url, parameters: Pexels.parameters, header: Pexels.headers)
        let pixaBay = Provider(name: ApiRequestType.pixaBay.rawValue, isOn: true, url: PixaBay.url, parameters: PixaBay.parameters)
        
        let splashSection = Sections(provider: splash, dataSource: [])
        let pixaBaySection = Sections(provider: pixaBay, dataSource: [])
        let pexelSection = Sections(provider: pexels, dataSource: [])
        self._sectionDataSource = [splashSection, pixaBaySection, pexelSection]
    }

    private func setupTable() {

        self.imageTableView.isHidden = true
        self.noImagesLabel.isHidden = false
        self.activityIndicator.isHidden = true
        self.imageTableView.reloadData()
    }
    
    // MARK: - Keyboard

    private func setupKeyboardHandlers() {
        
        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapDismiss)
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toFilter" {
            if let filterVC = segue.destination as? FilterViewController {
                
                var providers: [Provider] = []
                for section in self.sectionDataSource {
                    providers.append(section.provider)
                }
                
                filterVC.providerList = providers
                filterVC.imageFilterOn = self.imageFilterOn
                filterVC.providerDelegate = self
                filterVC.imageFilterDelegate = self
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension ImageListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.count < 5 { return }
        self.searchWorkItem?.cancel()

        // MARK: LoaderUI DispatchWorkItem
        let uiLoaderWork = DispatchWorkItem {
            self.noImagesLabel.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }

        // MARK: Search DispatchWorkItem
        self.searchWorkItem = DispatchWorkItem {
            
            DispatchQueue.main.async(execute: uiLoaderWork)
            let providerGroup = DispatchGroup()
            
            for (index, section) in self.sectionDataSource.enumerated() {
                
                let parameters = self.updateParameter(with: text, section.provider.parameters)
                providerGroup.enter()
                
                NetworkManager.shared.request(urlString: section.provider.url, headers: section.provider.header, parameters: parameters) { [section] dictionary in
                    
                    self.concurrentQueue.sync(flags: .barrier) {
                        self._sectionDataSource[index].dataSource = self.updatedSection(section.provider, dictionary)
                        providerGroup.leave()
                    }
                }
            }

            // MARK: Update UI w/ Results
            providerGroup.notify(queue: DispatchQueue.main) {

                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                if self.sectionDataSource.isEmpty {
                    self.noImagesLabel.isHidden = false
                    self.imageTableView.isHidden = true
                } else {
                    self.noImagesLabel.isHidden = true
                    self.imageTableView.isHidden = false
                    self.imageTableView.reloadData()
                }
            }
        }
        
        if let work = self.searchWorkItem {
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: work)
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

// MARK: - UITableViewDataSource

extension ImageListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.onSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.onSections[section].dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.reuseId,
                                                       for: indexPath) as? ImageTableViewCell else { fatalError("couldn't create ImageTableViewCell") }
        
        cell.setImage(with: self.onSections[indexPath.section].dataSource[indexPath.row].imageUrl ?? "", filter: self.imageFilterOn)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ImageListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionsOn = self.sectionDataSource.filter { $0.provider.isOn }
        return sectionsOn[section].provider.name
    }
}

// MARK: - ProviderDelegate

extension ImageListViewController: ProviderDelegate {

    func updateProviderIsOn(provider: Provider, isOn: Bool) {
        
        for (index, section) in self.sectionDataSource.enumerated() where section.provider == provider {
            self._sectionDataSource[index].provider.isOn = isOn
        }
        self.imageTableView.reloadData()
    }
}

// MARK: - ImageFilterDelegate

extension ImageListViewController: ImageFilterDelegate {
    
    func updateImageFilers(with filter: ImageFilterType) {
        
        self.imageFilterOn = filter
        self.imageTableView.reloadData()
    }
}

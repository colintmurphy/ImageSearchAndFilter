//
//  ViewController.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class GDCViewController: UIViewController {

    // MARK: - IBOutlets

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
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            self.activityIndicator.hidesWhenStopped = true
        }
    }
    @IBOutlet private weak var noImagesLabel: UILabel!
    @IBOutlet private weak var settingsButton: UIBarButtonItem!
    
    // MARK: - Dispatches
    
    private let concurrentQueue = DispatchQueue(label: "my.concurrent.queue", attributes: .concurrent)
    private var searchWorkItem: DispatchWorkItem?
    
    // MARK: - Variables
    
    private lazy var providers: [Provider] = {
        return [
            Provider(name: ApiRequestType.splash.rawValue, isOn: true, url: Splash.url, parameters: Splash.parameters),
            Provider(name: ApiRequestType.pexels.rawValue, isOn: true, url: Pexels.url, parameters: Pexels.parameters, headers: Pexels.headers),
            Provider(name: ApiRequestType.pixaBay.rawValue, isOn: true, url: PixaBay.url, parameters: PixaBay.parameters)
        ]
    }()
    
    private var _sectionDataSource: [Section] = []
    private var sectionDataSource: [Section] {
        self.concurrentQueue.sync {
            return self._sectionDataSource
        }
    }
    private var onSections: [Section] {
        return self.sectionDataSource.filter { $0.provider.isOn }
    }
    
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
    
    private func createSection(_ provider: Provider, _ dictionary: Any?) {
        
        guard let dictionary = dictionary as? [String: Any] else { return }
        var newSection: [ImageProtocol] = []
        
        switch provider.name {
        case Splash.name:
            guard let arrayItems = dictionary["images"] as? [[String: Any]], !arrayItems.isEmpty else { return }
            arrayItems.forEach { dictionary in
                newSection.append(SplashImageInfo(dict: dictionary))
            }
            let splash = Provider(name: ApiRequestType.splash.rawValue, isOn: true, url: Splash.url, parameters: Splash.parameters)
            let splashSection = Section(provider: splash, dataSource: newSection)
            self._sectionDataSource.append(splashSection)
            
        case Pexels.name:
            guard let arrayItems = dictionary["photos"] as? [[String: Any]], !arrayItems.isEmpty else { return }
            arrayItems.forEach { dictionary in
                newSection.append(PexelsImageInfo(dict: dictionary))
            }
            let pexels = Provider(name: ApiRequestType.pexels.rawValue, isOn: true, url: Pexels.url, parameters: Pexels.parameters, headers: Pexels.headers)
            let pexelsSection = Section(provider: pexels, dataSource: newSection)
            self._sectionDataSource.append(pexelsSection)
            
        case PixaBay.name:
            guard let arrayItems = dictionary["hits"] as? [[String: Any]], !arrayItems.isEmpty else { return }
            arrayItems.forEach { dictionary in
                newSection.append(PixabayImageInfo(dict: dictionary))
            }
            let pixaBay = Provider(name: ApiRequestType.pixaBay.rawValue, isOn: true, url: PixaBay.url, parameters: PixaBay.parameters)
            let pixaBaySection = Section(provider: pixaBay, dataSource: newSection)
            self._sectionDataSource.append(pixaBaySection)
            
        default:
            break
        }
    }

    // MARK: - Setup

    private func setup() {

        self.settingsButton.isEnabled = false
        self.tableView.isHidden = true
        self.noImagesLabel.isHidden = false
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

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toSettings" {
            if let settingsVC = segue.destination as? SettingsViewController {
                
                var providers: [Provider] = []
                for section in self.sectionDataSource {
                    providers.append(section.provider)
                }
                settingsVC.providerList = providers
                settingsVC.providerDelegate = self
            }
        }
        
        if segue.identifier == "toFilter" {
            if let filterVC = segue.destination as? FilterViewController,
               let indexPath = self.tableView.indexPathForSelectedRow {
                    
                let section = self.sectionDataSource[indexPath.section]
                let image = section.dataSource[indexPath.row]
                filterVC.image = image
                filterVC.imageIndexPath = indexPath
                filterVC.imageFilterDelegate = self
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension GDCViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.count < 5 { return }
        self.searchWorkItem?.cancel()

        // MARK: LoaderUI DispatchWorkItem
        let uiLoaderWork = DispatchWorkItem {
            
            self.noImagesLabel.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self._sectionDataSource.removeAll()
        }

        // MARK: Search DispatchWorkItem
        self.searchWorkItem = DispatchWorkItem {
            
            DispatchQueue.main.async(execute: uiLoaderWork)
            let providerGroup = DispatchGroup()
            
            for provider in self.providers {
                let parameters = self.updateParameter(with: query, provider.parameters)
                providerGroup.enter()
                
                NetworkManager.shared.request(urlString: provider.url, headers: provider.headers, parameters: parameters) { dictionary in
                    self.createSection(provider, dictionary)
                    providerGroup.leave()
                }
            }
            
            // MARK: Update UI w/ Results
            providerGroup.notify(queue: DispatchQueue.main) {
                self.activityIndicator.stopAnimating()

                if self.sectionDataSource.isEmpty {
                    self.settingsButton.isEnabled = false
                    self.noImagesLabel.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    self.settingsButton.isEnabled = true
                    self.noImagesLabel.isHidden = true
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            }
        }
        
        if let work = self.searchWorkItem {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: work)
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

extension GDCViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.onSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.onSections[section].dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: GDCTableViewCell.reuseId,
                                                       for: indexPath) as? GDCTableViewCell else { fatalError("couldn't create GDCTableViewCell") }
        
        let image = self.onSections[indexPath.section].dataSource[indexPath.row]
        cell.setImage(with: image.imageUrl ?? "", filter: image.filter)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension GDCViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.onSections[section].provider.name
    }
}

// MARK: - ProviderDelegate

extension GDCViewController: ProviderDelegate {

    func updateProviderIsOn(provider: Provider, isOn: Bool) {
        
        guard let index = self._sectionDataSource.firstIndex(where: { $0.provider == provider }) else { return }
        self._sectionDataSource[index].provider.isOn = isOn
        self.tableView.reloadData()
    }
}

// MARK: - ImageFilterDelegate

extension GDCViewController: ImageFilterDelegate {
    
    func updateImageFilter(of image: ImageProtocol, at index: IndexPath) {
        
        let provider = self.onSections[index.section].provider
        for (sectionIndex, section) in self._sectionDataSource.enumerated() where section.provider.name == provider.name {
            self._sectionDataSource[sectionIndex].dataSource[index.row].filter = image.filter
        }
        self.tableView.reloadRows(at: [index], with: .automatic)
        //self.imageTableView.reloadData()
    }
}

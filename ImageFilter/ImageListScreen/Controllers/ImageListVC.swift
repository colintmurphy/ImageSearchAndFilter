//
//  ViewController.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class ImageListVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noImagesLabel: UILabel!

    // MARK: - Variables

    private let concurrentQueue = DispatchQueue(label: "my.concurrent.queue", attributes: .concurrent)
    private var searchWorkItem: DispatchWorkItem?
    
    private var providerImageDict: [String: [ResponseImage]] = [:]
    private var sectionTitle: [String] = []
    var providerList: [(provider: Provider, isOn: Bool)] = []

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

    // MARK: - Setup

    private func setup() {

        self.searchBar.delegate = self
        self.createProviders()
        self.setupTable()
        self.setupKeyboardHandlers()
    }

    private func createProviders() {

        let splash = Provider(name: Splash.name, url: Splash.url, parameters: Splash.parameters)
        let pexels = Provider(name: Pexels.name, url: Pexels.url, parameters: Pexels.parameters, header: Pexels.headers)
        let pixaBay = Provider(name: PixaBay.name, url: PixaBay.url, parameters: PixaBay.parameters)
        
        self.providerList.append((provider: splash, isOn: true))
        self.providerList.append((provider: pexels, isOn: true))
        self.providerList.append((provider: pixaBay, isOn: true))
    }

    private func setupTable() {

        self.imageTableView.isHidden = true
        self.noImagesLabel.isHidden = false
        self.activityIndicator.isHidden = true
        self.imageTableView.reloadData()
    }

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
            if let filterVC = segue.destination as? FilterVC {

                filterVC.providerList = self.providerList
                filterVC.delegate = self
            }
        }
    }
}

// MARK: - ProviderDelegate

extension ImageListVC: ProviderDelegate {

    func updateProviderIsOn(provider: Provider, isOn: Bool) {

        /*
        var onCount = 0
        for provider in self.providerList {
            if provider.isOn {
                onCount += 1
            }
        }
        
        if onCount < 2 {
            return false
        } else {
         */
        
        for (index, providerItem) in self.providerList.enumerated() where providerItem.provider == provider {
            
            self.providerList[index].isOn = isOn
            self.imageTableView.reloadData()
            
            #warning("when to reload here???")
        }
    }
}

// MARK: - UITableViewDataSource

extension ImageListVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        
        var count = 0
        self.sectionTitle.removeAll()
        
        for provider in self.providerList where provider.isOn == true {
            self.sectionTitle.append(provider.provider.name)
            count += 1
        }
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        self.concurrentQueue.sync {
            if self.sectionTitle.count > 0 {
                
                let providerSection = self.sectionTitle[section]
                if let providers = self.providerImageDict[providerSection] {
                    return providers.count
                }
            }
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.reuseId, for: indexPath) as? ImageTableViewCell else { fatalError("couldn't create ImageTableViewCell") }

        let providerSection = self.sectionTitle[indexPath.section]
        if let providers = self.providerImageDict[providerSection] {
            
            if let imageUrl = providers[indexPath.row].src?.small {
                self.concurrentQueue.sync(flags: .barrier) { cell.setImage(with: imageUrl) }
            } else if let imageUrl = providers[indexPath.row].url {
                self.concurrentQueue.sync(flags: .barrier) { cell.setImage(with: imageUrl) }
            } else if let imageUrl = providers[indexPath.row].webformatURL {
                self.concurrentQueue.sync(flags: .barrier) { cell.setImage(with: imageUrl) }
            } else {
                print("BAD")
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ImageListVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitle[section]
    }
}

// MARK: - UISearchBarDelegate

extension ImageListVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.count <= 5 { return }
        self.searchWorkItem?.cancel()

        let uiLoaderWork = DispatchWorkItem {

            self.noImagesLabel.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }

        self.searchWorkItem = DispatchWorkItem {

            DispatchQueue.main.async(execute: uiLoaderWork)
            
            let providerGroup = DispatchGroup()
            for provider in self.providerList where provider.isOn {

                providerGroup.enter()
                DispatchQueue.global().async {

                    let parameters = self.updateParameter(with: text, provider.provider.parameters)
                        
                    self.concurrentQueue.sync(flags: .barrier) {
                        NetworkManager.shared.request(urlString: provider.provider.url, headers: provider.provider.header, parameters: parameters) { (responseImageArray) in
                                
                            if let images = responseImageArray {
                                self.providerImageDict[provider.provider.name] = images
                                providerGroup.leave()
                            } else {
                                providerGroup.leave()
                            }
                        }
                    }
                }
            }

            providerGroup.notify(queue: DispatchQueue.main) {

                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.imageTableView.isHidden = false
                self.imageTableView.reloadData()
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

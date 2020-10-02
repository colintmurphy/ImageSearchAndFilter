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
    private var providerImageDict: [String: [ProviderImage]] = [:]
    private var sectionTitle: [String] = []
    var providerList: [(provider: Provider, isOn: Bool)] = []

    // MARK: - View Life Cycles

    override func viewDidLoad() {

        super.viewDidLoad()
        self.setup()
    }

    // MARK: - Setup

    private func setup() {

        self.searchBar.delegate = self
        self.createProviders()
        self.setupTable()
        self.setupKeyboardHandlers()
    }

    private func createProviders() {

        let splash = Provider(name: "Splash", url: "http://www.splashbase.co/api/v1/images/search?query=")
        self.providerList.append((provider: splash, isOn: true))
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

        for (index, providerItem) in self.providerList.enumerated() where providerItem.provider == provider {
            
            self.providerList[index].isOn = isOn
            
            #warning("when to reload here???")
        }
    }
}

// MARK: - UISearchBarDelegate

extension ImageListVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.count < 5 { return }

        let uiLoaderWork = DispatchWorkItem {
            
            self.noImagesLabel.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }

        let workItem = DispatchWorkItem {

            DispatchQueue.main.async(execute: uiLoaderWork)
            let providerGroup = DispatchGroup()

            for provider in self.providerList where provider.isOn {

                guard let url = URL(string: provider.provider.url + searchText) else { continue }
                providerGroup.enter()

                DispatchQueue.global().async {
                    do {
                        let data = try NSData(contentsOf: url, options: .mappedIfSafe) as Data
                        let responseObj = try JSONDecoder().decode(ProviderImages.self, from: data)
                        if let images = responseObj.images {

                            self.concurrentQueue.sync(flags: .barrier) {
                                self.providerImageDict[provider.provider.name] = images
                            }
                        }
                        providerGroup.leave()
                    } catch {
                        print(error)
                        providerGroup.leave()
                    }
                }
            }

            providerGroup.notify(queue: DispatchQueue.main) {

                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true

                self.imageTableView.isHidden = false
                self.imageTableView.reloadData()

                print("providerImageDict: ", self.providerImageDict)
                print("providerList: ", self.providerList)
            }
        }

        //if let workItem = imagesWorkItem {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: workItem)
        //}
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        print("started editing")
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        print("stopped editing")
        searchBar.showsCancelButton = false
    }
}

// MARK: - UITableViewDelegate

extension ImageListVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.providerList[section].provider.name
    }
}

// MARK: - UITableViewDataSource

extension ImageListVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        var count = 0
        for provider in self.providerList where provider.isOn {
            count += 1
        }
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        self.concurrentQueue.sync {
            if self.sectionTitle.count > 1 {
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

        self.concurrentQueue.sync {

            let providerSection = self.sectionTitle[indexPath.section]
            if let providers = self.providerImageDict[providerSection],
               let imageUrl = providers[indexPath.row].url {

                cell.setImage(with: imageUrl)
            }
        }

        return cell
    }
}

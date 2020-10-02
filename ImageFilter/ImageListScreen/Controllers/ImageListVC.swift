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

    var providerList: [(provider: Provider, isOn: Bool)] = []
    private var providerImageDict: [String: [UIImage]] = [:]
    private var sectionTitle: [String] = []

    // MARK: - View Life Cycles

    override func viewDidLoad() {

        super.viewDidLoad()
        self.setup()
    }

    // MARK: - Setup

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    private func setup() {

        self.searchBar.delegate = self
        self.createProviders()
        self.setupTable()
        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapDismiss)
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

        if self.sectionTitle.count > 1 {
            let providerSection = self.sectionTitle[section]
            if let providers = self.providerImageDict[providerSection] {

                return providers.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.reuseId, for: indexPath) as? ImageTableViewCell else { fatalError("couldn't create ImageTableViewCell") }

        let providerSection = self.sectionTitle[indexPath.section]
        if let providers = self.providerImageDict[providerSection] {
            cell.setImage(with: providers[indexPath.row])
        }
        return cell
    }
}

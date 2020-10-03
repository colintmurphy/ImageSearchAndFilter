//
//  FilterVC.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class FilterVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var providerTableView: UITableView!

    // MARK: - Variables

    var providerList: [(provider: Provider, isOn: Bool)]?
    weak var delegate: ProviderDelegate?
    private var numberOfFiltersOn: Int?

    // MARK: - View Life Cycles

    override func viewDidLoad() {

        super.viewDidLoad()
        self.setupTableView()
    }

    // MARK: - Setup

    private func setupTableView() {
        self.providerTableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource

extension FilterVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.providerList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProviderTableViewCell.reuseId,
            for: indexPath) as? ProviderTableViewCell else { fatalError("couldn't create ProviderTableViewCell") }

        if let providerItem = self.providerList?[indexPath.row] {
            cell.delegate = self.delegate
            cell.oneDelegate = self
            cell.set(provider: providerItem)
        }
        
        #warning("need to send alert if try to turn the last ON to OFF")

        return cell
    }
}

// MARK: - OneOnDelegate

protocol OneOnDelegate: class {
    func sendAlert()
}

extension FilterVC: OneOnDelegate {
    
    func sendAlert() {
        self.showAlert(title: "Sorry", message: "You need to keep at least one filter on.")
    }
}

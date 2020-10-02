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

// MARK: - UITableViewDelegate

extension FilterVC: UITableViewDelegate {


}

// MARK: - UITableViewDataSource

extension FilterVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let providerCount = self.providerList?.count {
            return providerCount
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProviderTableViewCell.reuseId,
            for: indexPath) as? ProviderTableViewCell else { fatalError("couldn't create ProviderTableViewCell") }

        if let providerItem = self.providerList?[indexPath.row] {
            cell.set(name: providerItem.provider.name, isOn: providerItem.isOn, provider: providerItem.provider)
            cell.delegate = self.delegate
        }

        return cell
    }
}

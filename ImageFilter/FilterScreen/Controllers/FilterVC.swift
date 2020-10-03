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
            cell.switchDelegate = self
            cell.set(provider: providerItem)
        }

        return cell
    }
}

// MARK: - OneOnDelegate

extension FilterVC: SwitchDelegate {
    
    func shouldSwitchChange(provider: Provider, isOn: Bool) -> Bool {
        
        guard let providerList = self.providerList else { return true }
        
        var count = 0
        for provider in providerList where provider.isOn { count += 1 }
        
        if !isOn && count < 2 {
            self.showAlert(title: "Sorry", message: "At least one filter must on.")
            return false
        }
        
        for (index, providerItem) in providerList.enumerated() where providerItem.provider == provider {
            self.providerList?[index].isOn = isOn
        }
        return true
    }
}

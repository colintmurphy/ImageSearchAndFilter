//
//  SettingsViewController.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var settingsTableView: UITableView!

    // MARK: - Variables
    
    var providerList: [Provider]?
    private var numberOfProvidersOn: Int?
    private var settingsTypes: [SettingsType] = []
    
    // MARK: - Delegates
    
    weak var providerDelegate: ProviderDelegate?

    // MARK: - View Life Cycles

    override func viewDidLoad() {

        super.viewDidLoad()
        self.setupTableView()
        self.setupData()
    }

    // MARK: - Setup

    private func setupTableView() {
        self.settingsTableView.tableFooterView = UIView()
    }
    
    private func setupData() {
        self.settingsTypes = Array(repeating: SettingsType.provider, count: self.providerList?.count ?? 0)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsType.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch SettingsType(rawValue: section) {
        case .provider:
            return self.providerList?.count ?? 0
            
        case .filter:
            return 0
            
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch SettingsType(rawValue: section) {
        case .provider:
            return "Providers"
            
        case .filter:
            return ""
            
        case .none:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch SettingsType(rawValue: indexPath.section) {
        case .provider:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProviderTableViewCell.reuseId,
                                                           for: indexPath) as? ProviderTableViewCell else { fatalError("couldn't create ProviderTableViewCell") }

            if let providerItem = self.providerList?[indexPath.row] {
                cell.delegate = self.providerDelegate
                cell.switchDelegate = self
                cell.set(provider: providerItem)
            }
            cell.selectionStyle = .none
            return cell
            
        case .filter:
            fatalError("filter cell should not be here")
            
        case .none:
            fatalError("couldn't create cell with SettingsType")
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch SettingsType(rawValue: indexPath.section) {
        case .provider:
            return
            
        case .filter:
            return
            
        case .none:
            return
        }
    }
}

// MARK: - SwitchDelegate

extension SettingsViewController: SwitchDelegate {
    
    func shouldSwitchChange(provider: Provider, isOn: Bool) -> Bool {
        
        guard let providerList = self.providerList else { return true }
        let providerOnCount = providerList.filter { $0.isOn }.count
        
        if !isOn && providerOnCount == 1 {
            self.showAlert(title: "Sorry", message: "At least one filter must on.")
            return false
        } else {
            for (index, providerItem) in providerList.enumerated() where providerItem.name == provider.name {
                self.providerList?[index].isOn = isOn
            }
            return true
        }
    }
}

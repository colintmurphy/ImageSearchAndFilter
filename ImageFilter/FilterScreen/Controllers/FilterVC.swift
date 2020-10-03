//
//  FilterVC.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class FilterVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var settingsTableView: UITableView!

    // MARK: - Variables
    
    var providerList: [(provider: Provider, isOn: Bool)]?
    var imageFilterOn: ImageFilterType?
    private var numberOfProvidersOn: Int?
    private var imageFilterTypes: [ImageFilterType] = [.original, .blackWhite, .sepia, .bloom]
    private var settingsTypes: [SettingsType] = []
    
    // MARK: - Delegates
    
    weak var providerDelegate: ProviderDelegate?
    weak var imageFilterDelegate: ImageFilterDelegate?

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
            + Array(repeating: SettingsType.filter, count: self.imageFilterTypes.count)
    }
}

// MARK: - UITableViewDataSource

extension FilterVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsType.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch SettingsType.init(rawValue: section) {
        case .provider:
            return self.providerList?.count ?? 0
        case .filter:
            return self.imageFilterTypes.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch SettingsType.init(rawValue: section) {
        case .provider:
            return "Providers"
        case .filter:
            return "Filters"
        case .none:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch SettingsType.init(rawValue: indexPath.section) {
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
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageFilterTableViewCell.reuseId,
                for: indexPath) as? ImageFilterTableViewCell else { fatalError("couldn't create ImageFilterTableViewCell") }
            
            cell.set(name: self.imageFilterTypes[indexPath.row].rawValue)
            cell.selectionStyle = .default
            cell.accessoryType = .none
            
            if self.imageFilterOn != nil &&
                self.imageFilterOn == self.imageFilterTypes[indexPath.row] {
                cell.accessoryType = .checkmark
            }
            return cell
            
        case .none:
            fatalError("couldn't create cell with SettingsType")
        }
    }
}

// MARK: - UITableViewDelegate

extension FilterVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch SettingsType.init(rawValue: indexPath.section) {
        case .provider:
            return
        case .filter:
            self.imageFilterOn = self.imageFilterTypes[indexPath.row]
            guard let filter = self.imageFilterOn else { return }
            self.imageFilterDelegate?.updateImageFilers(with: filter)
            
            tableView.deselectRow(at: indexPath, animated: true)
            self.settingsTableView.reloadData()
            
        case .none:
            return
        }
    }
}

// MARK: - SwitchDelegate

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

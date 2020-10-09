//
//  JSONOperation.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/9/20.
//

import Foundation

class JSONOperation: Operation {
    
    // MARK: - Variables
    
    var section: Section?
    private var query: String
    private var provider: Provider
    
    // MARK: - Override Operation Variables
    
    private var _isFinished = false
    override var isFinished: Bool {
        get {
            return self._isFinished
        }
        set {
            if self._isFinished != newValue {
                willChangeValue(forKey: "isFinished")
                self._isFinished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    // MARK: - Init
    
    init(_ query: String, provider: Provider) {
        
        self.provider = provider
        self.query = query
    }
    
    // MARK: - Start
    
    override func start() {
        
        if isCancelled { return }
        
        let parameters = self.updateParameter(withQueryString: query, andDict: provider.parameters)
        NetworkManager.shared.request(urlString: provider.url, headers: provider.headers, parameters: parameters) { dictionary in
            
            if self.isCancelled { return }
            
            if let dictionary = dictionary as? [String: Any] {
                self.createSection(self.provider, dictionary)
                self.isFinished = true
            } else {
                self.isFinished = true
            }
        }
    }
    
    // MARK: - Update Dict Helper Methods
    
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
            self.section = Section(provider: splash, dataSource: newSection)
            
        case Pexels.name:
            guard let arrayItems = dictionary["photos"] as? [[String: Any]], !arrayItems.isEmpty else { return }
            arrayItems.forEach { dictionary in
                newSection.append(PexelsImageInfo(dict: dictionary))
            }
            let pexels = Provider(name: ApiRequestType.pexels.rawValue, isOn: true, url: Pexels.url, parameters: Pexels.parameters, headers: Pexels.headers)
            self.section = Section(provider: pexels, dataSource: newSection)
            
        case PixaBay.name:
            guard let arrayItems = dictionary["hits"] as? [[String: Any]], !arrayItems.isEmpty else { return }
            arrayItems.forEach { dictionary in
                newSection.append(PixabayImageInfo(dict: dictionary))
            }
            let pixaBay = Provider(name: ApiRequestType.pixaBay.rawValue, isOn: true, url: PixaBay.url, parameters: PixaBay.parameters)
            self.section = Section(provider: pixaBay, dataSource: newSection)
            
        default:
            break
        }
    }
    
    private func updateParameter(withQueryString query: String, andDict: [String: String]) -> [String: String] {
        
        var parameters = andDict
        if parameters["query"] != nil {
            parameters["query"] = query
        } else if parameters["q"] != nil {
            parameters["q"] = query
        }
        return parameters
    }
}

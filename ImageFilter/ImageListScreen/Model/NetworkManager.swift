//
//  NetworkManager.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class NetworkManager {
    
    // MARK: - Variables
    
    static let shared = NetworkManager()
    private let cache = NSCache<NSString, CIImage>()
    
    // MARK: - Init
    
    private init() { }
    
    // MARK: - Requests

    func request(urlString: String, headers: [String: String]?, parameters: [String: String]?, completed: @escaping (Any?) -> Void) {
        
        guard var urlComponents = URLComponents(string: urlString) else { return }
        
        if let parameters = parameters {
            var elements: [URLQueryItem] = []
            
            for (key, value) in parameters {
                elements.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = elements
        }
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil, let data = data else {
                completed(nil)
                return
            }
            do {
                let dataDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completed(dataDict)
            } catch {
                print(error)
                completed(nil)
            }
        }.resume()
    }
    
    func downloadFilterImage(with imageUrl: String, filter: ImageFilterType, completed: @escaping (UIImage?) -> Void) {
        
        self.downloadImage(with: imageUrl) { image in
            if let originalCIImage = image {
                var newImage = UIImage(ciImage: originalCIImage)
                
                switch filter {
                case .original:
                    break
                    
                case .blackWhite:
                    if let ciImage = self.setFilter(originalCIImage, filterType: CIFilterType.blackWhite) {
                        newImage = UIImage(ciImage: ciImage)
                    }
                    
                case .sepia:
                    if let ciImage = self.setFilter(originalCIImage, filterType: CIFilterType.sepia) {
                        newImage = UIImage(ciImage: ciImage)
                    }
                    
                case .bloom:
                    if let ciImage = self.setFilter(originalCIImage, filterType: CIFilterType.bloom),
                       let cgOutputImage = CIContext().createCGImage(ciImage, from: originalCIImage.extent) {
                        newImage = UIImage(cgImage: cgOutputImage)
                    }
                }
                completed(newImage)
                return
            } else {
                completed(nil)
                return
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func downloadImage(with imageUrl: String, completed: @escaping (CIImage?) -> Void) {
        
        let cacheKey = NSString(string: imageUrl)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        DispatchQueue.global().async {
            if let url = URL(string: imageUrl),
                let image = CIImage(contentsOf: url) {
                completed(image)
                return
            } else {
                completed(nil)
                return
            }
        }
    }
    
    private func setFilter(_ input: CIImage, filterType: CIFilterType) -> CIImage? {
        
        let filter = CIFilter(name: filterType.rawValue)
        filter?.setValue(input, forKey: kCIInputImageKey)
        
        switch filterType {
        case .blackWhite:
            filter?.setValue(0.0, forKey: kCIInputSaturationKey)
            filter?.setValue(0.9, forKey: kCIInputContrastKey)
            
        case .sepia, .bloom:
            filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        }
        return filter?.outputImage
    }
}

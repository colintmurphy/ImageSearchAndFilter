//
//  NetworkManager.swift
//  ImageFilter
//
//  Created by Colin Murphy on 10/2/20.
//

import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() { }
    
    func request(urlString: String, headers: [String: String]?, parameters: [String: String]?, completed: @escaping ([ResponseImage]?) -> Void) {
        
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
           
            if error != nil { print(error!) }
            guard let data = data else { return }
            
            do {
                let obj = try JSONDecoder().decode(ApiResponse.self, from: data)
                
                if let image = obj.hits {
                    completed(image); return
                } else if let image = obj.photos {
                    completed(image); return
                } else if let image = obj.images {
                    completed(image); return
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func downloadImage(with imageUrl: String, completed: @escaping (UIImage?) -> Void) {
        
        let cacheKey = NSString(string: imageUrl)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }

        DispatchQueue.global().async {
            guard let url = URL(string: imageUrl) else { completed(nil); return }
            do {
                let data = try Data(contentsOf: url)
                completed(UIImage(data: data))
                return
            } catch {
                print(error)
                completed(nil)
                return
            }
        }
    }
}

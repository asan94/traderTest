//
//  ImageLoader.swift
//  TraderTest
//
//  Created by Asan Ametov on 02.03.2026.
//

import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    private let session = URLSession.shared
    
    private init() {
        cache.countLimit = 50  // max 50 images
        cache.totalCostLimit = 50 * 1024 * 1024  // 50MB
    }
    
    func load(urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        let cacheKey = urlString as NSString
        
        // 1. Check cach
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage, nil)
            return
        }
        
        // 2. Load from url
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data,
                      error == nil,
                      let image = UIImage(data: data) else {
                    completion(nil, error)
                    return
                }
                
                // 3. cach
                self.cache.setObject(image, forKey: cacheKey, cost: data.count)
                
                completion(image, nil)
            }
        }
        task.resume()
    }
}


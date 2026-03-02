//
//  UIImageView+extension.swift
//  TraderTest
//
//  Created by Asan Ametov on 01.03.2026.
//

import UIKit

extension UIImageView {
    
    func load(urlString: String, completion: (() -> Void)? = nil) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                self?.image = nil
                self?.isHidden = true
                return
            }

            DispatchQueue.main.async {
                if image.size.width > 5 {
                    self.image = image
                    self.isHidden = false
                } else {
                    self.image = nil
                    self.isHidden = true
                }
            }
        }
        task.resume()
    }
    
    func load(urlString: String, completion: @escaping @Sendable (UIImage?, (any Error)?)-> Void) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                guard let self = self,
                      let data = data,
                      error == nil,
                      let image = UIImage(data: data) else {
                    completion(nil, error)
                    return
                }
                self.image = image
                self.isHidden = false
                completion(image, nil)
            }
        }
        task.resume()
    }
}

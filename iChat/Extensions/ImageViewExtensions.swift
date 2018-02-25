//
//  ImageViewExtensions.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/19/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setImage(urlStr: String?) {
        guard let urlStr = urlStr, let url = URL(string:urlStr)  else {
            return
        }
        setImage(url: url)
    }
    
    func setImage(url: URL?) {
        
        guard  let url = url  else {
            return
        }
        getImage(from: url) { (image) in
            self.image = image
        }
        
    }
    
    /// Download Image from url
    func getImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil)
                } else {
                    
                    if let data = data {
                        let image = UIImage(data: data)
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
        task.resume()
    }
    
}

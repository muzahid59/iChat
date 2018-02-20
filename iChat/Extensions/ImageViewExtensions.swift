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
        
//        weak var spinner: UIActivityIndicatorView ()
//        translatesAutoresizingMaskIntoConstraints = false
//        spinner.center = self.center
//        spinner.startAnimating()
//        addSubview(spinner)
        guard let urlStr = urlStr, let url = URL(string:urlStr)  else {
//            spinner.stopAnimating()
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let data = data {
                        let image = UIImage(data: data)
                        self.image = image
                    }
                   
                }
            }
            }.resume()
    }
    func setImage(url: URL?) {
        
        guard  let url = url  else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let data = data {
                        let image = UIImage(data: data)
                        self.image = image
                    }
                }
            }
            }.resume()
    }
}

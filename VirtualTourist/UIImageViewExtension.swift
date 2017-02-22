//
//  UIImageViewExtension.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/23/17.
//
// Credits: http://stackoverflow.com/a/37019507/2925286
//

import UIKit

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL) { (data, response, error) in
            
            if error != nil {
                print(error ?? "Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }.resume()
    }
}

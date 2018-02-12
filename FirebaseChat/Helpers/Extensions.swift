//
//  Extensions.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/11/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageWithCache(using urlString: String) {
        
        self.image = nil
        
        //check cache and fetch images
        if let cachedImg = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImg
            return
        }
        
        //else download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as AnyObject)
                     self.image = image
                }
            }
        }).resume()
    }
}


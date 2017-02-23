//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/18/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(title: String, imageUrl: String, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.title = title
            self.imgObject = nil
            
            downloadPhoto(url: URL(string: imageUrl)!)
        } else {
            fatalError("DB error: could not find entity model name.")
        }
    }
    
    func downloadPhoto(url: URL) {
        getImageAsync(url: url) { (data, response, error)  in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async() { () -> Void in
                self.imgObject = data as NSData
            }
        }
    }
}

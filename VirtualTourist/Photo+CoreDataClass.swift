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
    
    convenience init(title: String, image: NSData, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.title = title
            self.imgObject = image
        } else {
            fatalError("DB error: could not find entity model name.")
        }
    }
    
    private func imageFromUrl(_ url: String) -> UIImage? {
        let imageURL = NSURL(string: url)
        if let imageData = NSData(contentsOf: imageURL! as URL) {
            return UIImage(data: imageData as Data)
        } else {
            return nil
        }
    }
}

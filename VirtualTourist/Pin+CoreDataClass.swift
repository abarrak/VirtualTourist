//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/18/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(title: String, latitude: Double, longtitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.title = title
            self.latitude = latitude
            self.longtitude = longtitude
            self.createdAt = NSDate()
        } else {
            fatalError("DB error: could not find entity model name.")
        }
    }
}

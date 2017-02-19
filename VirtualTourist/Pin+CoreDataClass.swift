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
    
    // Mark: - Initializers
    
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
    
    // Mark: - Finder methods

    static func all(context: NSManagedObjectContext) -> [Pin]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            let results = try context.fetch(fetchRequest) as! [Pin]
            return results
        } catch {
            return nil
        }
    }
    
    static func find(context: NSManagedObjectContext, id: Int) -> Pin? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try context.fetch(fetchRequest) as! [Pin]
            return results.first!
        } catch {
            return nil
        }
    }
}

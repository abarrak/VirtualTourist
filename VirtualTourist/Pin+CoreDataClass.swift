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
    
    convenience init(title: String, latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.title = title
            self.latitude = latitude
            self.longitude = longitude
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
    
    static func find(_ id: Int, context: NSManagedObjectContext) -> Pin? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest) as! [Pin]
            return results.first
        } catch {
            return nil
        }
    }
    
    static func findBy(latitude: Double, longitude: Double, context: NSManagedObjectContext) -> Pin? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let p1 = NSPredicate(format: "latitude = %lf", latitude)
        let p2 = NSPredicate(format: "longitude = %lf", longitude)
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [p1, p2])

        do {
            let results = try context.fetch(fetchRequest) as! [Pin]
            return results.first
        } catch {
            return nil
        }
    }
    
    func deleteAllPhotos(context: NSManagedObjectContext) -> Bool {
        // Drop all related photos to the model instance
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin = %@", self)
        
        do {
            let results = try context.fetch(fetchRequest) as! [Photo]
            self.removeFromPhotos(NSSet(array: results))
            return true
        } catch {
            return false
        }
    }
}

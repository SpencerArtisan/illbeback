//
//  FlagEntity+CoreDataProperties.swift
//  
//
//  Created by Spencer Kennedy Ward on 17/02/2020.
//
//

import Foundation
import CoreData


extension FlagEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlagEntity> {
        return NSFetchRequest<FlagEntity>(entityName: "FlagEntity")
    }

    @NSManaged public var encoded: String?
    @NSManaged public var id: String?

}

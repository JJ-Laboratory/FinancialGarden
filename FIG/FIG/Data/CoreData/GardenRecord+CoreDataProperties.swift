//
//  GardenRecord+CoreDataProperties.swift
//  FIG
//
//  Created by Milou on 8/20/25.
//
//

import Foundation
import CoreData


extension GardenRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GardenRecord> {
        return NSFetchRequest<GardenRecord>(entityName: "GardenRecord")
    }

    @NSManaged public var totalSeeds: Int16
    @NSManaged public var totalFruits: Int16

}

extension GardenRecord : Identifiable {

}

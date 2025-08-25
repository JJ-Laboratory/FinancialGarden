//
//  GardenRecordEntity+CoreDataProperties.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//
//

import Foundation
import CoreData


extension GardenRecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GardenRecordEntity> {
        return NSFetchRequest<GardenRecordEntity>(entityName: "GardenRecordEntity")
    }

    @NSManaged public var totalFruits: Int16
    @NSManaged public var totalSeeds: Int16

}

extension GardenRecordEntity : Identifiable {

}

//
//  Challenge+CoreDataProperties.swift
//  FIG
//
//  Created by Milou on 8/20/25.
//
//

import Foundation
import CoreData


extension Challenge {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Challenge> {
        return NSFetchRequest<Challenge>(entityName: "Challenge")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var categoryID: UUID?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var duration: String?
    @NSManaged public var spendingLimit: Int32
    @NSManaged public var targetFruitsCount: Int16
    @NSManaged public var requiredSeedCount: Int16
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isSuccess: Bool

}

extension Challenge : Identifiable {

}

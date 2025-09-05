//
//  ChallengeEntity+CoreDataProperties.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//
//

import Foundation
import CoreData


extension ChallengeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChallengeEntity> {
        return NSFetchRequest<ChallengeEntity>(entityName: "ChallengeEntity")
    }

    @NSManaged public var categoryID: UUID?
    @NSManaged public var duration: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var status: String?
    @NSManaged public var requiredSeedCount: Int16
    @NSManaged public var spendingLimit: Int32
    @NSManaged public var startDate: Date?
    @NSManaged public var targetFruitsCount: Int16

}

extension ChallengeEntity : Identifiable {

}

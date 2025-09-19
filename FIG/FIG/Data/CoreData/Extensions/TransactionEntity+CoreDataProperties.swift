//
//  TransactionEntity+CoreDataProperties.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//
//

import Foundation
import CoreData


extension TransactionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        return NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }

    @NSManaged public var amount: Int64
    @NSManaged public var categoryID: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var memo: String?
    @NSManaged public var paymentMethod: String?
    @NSManaged public var title: String?

}

extension TransactionEntity : Identifiable {

}

//
//  Transaction+CoreDataProperties.swift
//  FIG
//
//  Created by Milou on 8/20/25.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: Int32
    @NSManaged public var categoryID: UUID?
    @NSManaged public var title: String?
    @NSManaged public var paymentMethod: String?
    @NSManaged public var memo: String?
    @NSManaged public var date: Date?

}

extension Transaction : Identifiable {

}

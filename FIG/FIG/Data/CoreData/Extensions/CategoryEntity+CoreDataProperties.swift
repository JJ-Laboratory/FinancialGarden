//
//  CategoryEntity+CoreDataProperties.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//
//

import Foundation
import CoreData


extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var iconName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isDefault: Bool
    @NSManaged public var title: String?
    @NSManaged public var transactionType: String?

}

extension CategoryEntity : Identifiable {

}

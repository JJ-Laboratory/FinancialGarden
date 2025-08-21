//
//  Category+CoreDataProperties.swift
//  FIG
//
//  Created by Milou on 8/20/25.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var iconName: String?
    @NSManaged public var transactionType: String?
    @NSManaged public var isDefault: Bool

}

extension Category : Identifiable {

}

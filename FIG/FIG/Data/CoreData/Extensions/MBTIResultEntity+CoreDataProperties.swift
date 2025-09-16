//
//  MBTIResultEntity+CoreDataProperties.swift
//  FIG
//
//  Created by estelle on 9/16/25.
//
//

import Foundation
import CoreData


extension MBTIResultEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MBTIResultEntity> {
        return NSFetchRequest<MBTIResultEntity>(entityName: "MBTIResultEntity")
    }

    @NSManaged public var mbti: String?
    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var recommend: String?
    @NSManaged public var id: Int16

}

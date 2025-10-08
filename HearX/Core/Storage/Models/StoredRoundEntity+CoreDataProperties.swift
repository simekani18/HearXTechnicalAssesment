//
//  StoredRoundEntity+CoreDataProperties.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/08.
//

import Foundation
import CoreData

extension StoredRoundEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredRoundEntity> {
        return NSFetchRequest<StoredRoundEntity>(entityName: "StoredRoundEntity")
    }

    @NSManaged public var difficulty: Int16
    @NSManaged public var tripletPlayed: String
    @NSManaged public var tripletAnswered: String
    @NSManaged public var session: TestSessionEntity?
}

extension StoredRoundEntity: Identifiable {
}

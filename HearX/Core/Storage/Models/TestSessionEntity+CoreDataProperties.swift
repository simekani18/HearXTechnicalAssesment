//
//  TestSessionEntity+CoreDataProperties.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/08.
//

import Foundation
import CoreData

extension TestSessionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestSessionEntity> {
        return NSFetchRequest<TestSessionEntity>(entityName: "TestSessionEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var score: Int16
    @NSManaged public var rounds: NSOrderedSet?
}

// MARK: Generated accessors for rounds
extension TestSessionEntity {
    @objc(insertObject:inRoundsAtIndex:)
    @NSManaged public func insertIntoRounds(_ value: StoredRoundEntity, at idx: Int)

    @objc(removeObjectFromRoundsAtIndex:)
    @NSManaged public func removeFromRounds(at idx: Int)

    @objc(insertRounds:atIndexes:)
    @NSManaged public func insertIntoRounds(_ values: [StoredRoundEntity], at indexes: NSIndexSet)

    @objc(removeRoundsAtIndexes:)
    @NSManaged public func removeFromRounds(at indexes: NSIndexSet)

    @objc(replaceObjectInRoundsAtIndex:withObject:)
    @NSManaged public func replaceRounds(at idx: Int, with value: StoredRoundEntity)

    @objc(replaceRoundsAtIndexes:withRounds:)
    @NSManaged public func replaceRounds(at indexes: NSIndexSet, with values: [StoredRoundEntity])

    @objc(addRoundsObject:)
    @NSManaged public func addToRounds(_ value: StoredRoundEntity)

    @objc(removeRoundsObject:)
    @NSManaged public func removeFromRounds(_ value: StoredRoundEntity)

    @objc(addRounds:)
    @NSManaged public func addToRounds(_ values: NSOrderedSet)

    @objc(removeRounds:)
    @NSManaged public func removeFromRounds(_ values: NSOrderedSet)
}

extension TestSessionEntity: Identifiable {
}

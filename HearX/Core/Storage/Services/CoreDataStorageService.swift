//
//  CoreDataStorageService.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/08.
//

import Foundation
import CoreData

@MainActor
final class CoreDataStorageService: StorageServiceProtocol {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = .shared) throws {
        self.coreDataStack = coreDataStack

        guard coreDataStack.persistentContainer.persistentStoreCoordinator.persistentStores.isEmpty == false else {
            throw StorageError.contextUnavailable
        }
    }

    func saveTestSession(_ session: TestSession) async throws {
        let context = coreDataStack.viewContext

        do {
            let entity = TestSessionEntity(context: context)
            entity.id = session.id
            entity.date = session.date
            entity.score = Int16(session.score)

            let roundEntities = session.rounds.map { round -> StoredRoundEntity in
                let roundEntity = StoredRoundEntity(context: context)
                roundEntity.difficulty = Int16(round.difficulty)
                roundEntity.tripletPlayed = round.tripletPlayed
                roundEntity.tripletAnswered = round.tripletAnswered
                roundEntity.session = entity
                return roundEntity
            }

            entity.rounds = NSOrderedSet(array: roundEntities)

            try coreDataStack.saveContext()
        } catch {
            throw StorageError.saveFailed
        }
    }

    func fetchTestSessions() async throws -> [TestSession] {
        let context = coreDataStack.viewContext

        do {
            let fetchRequest = TestSessionEntity.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "score", ascending: false),
                NSSortDescriptor(key: "date", ascending: false)
            ]

            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { mapToDomainModel($0) }
        } catch {
            throw StorageError.fetchFailed
        }
    }

    func deleteTestSession(id: UUID) async throws {
        let context = coreDataStack.viewContext

        do {
            let fetchRequest = TestSessionEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            let entities = try context.fetch(fetchRequest)
            guard let entity = entities.first else { return }

            context.delete(entity)
            try coreDataStack.saveContext()
        } catch {
            throw StorageError.deleteFailed
        }
    }

    private func mapToDomainModel(_ entity: TestSessionEntity) -> TestSession? {
        let rounds: [StoredRound] = (entity.rounds?.array as? [StoredRoundEntity])?.map { roundEntity in
            StoredRound(
                difficulty: Int(roundEntity.difficulty),
                tripletPlayed: roundEntity.tripletPlayed,
                tripletAnswered: roundEntity.tripletAnswered
            )
        } ?? []

        return TestSession(
            id: entity.id,
            date: entity.date,
            score: Int(entity.score),
            rounds: rounds
        )
    }
}

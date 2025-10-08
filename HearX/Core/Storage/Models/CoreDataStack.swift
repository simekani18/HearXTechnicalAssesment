//
//  CoreDataStack.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/08.
//

import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private let modelName: String

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData: Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(modelName: String = "HearXDataModel") {
        self.modelName = modelName
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    func saveContext() throws {
        let context = viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            throw StorageError.saveFailed
        }
    }

    func saveContext(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            throw StorageError.saveFailed
        }
    }
}

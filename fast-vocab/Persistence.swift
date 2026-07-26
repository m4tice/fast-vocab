import CoreData
import Foundation

enum PersistenceError: Error, Equatable {
    case invalidData
    case saveFailed
}

@MainActor
protocol PersistenceRepository {
    func loadSession() throws -> SessionPersistence?
    func saveSession(_ snapshot: SessionPersistence) throws
    func deleteSession() throws
    func loadUserProgress() throws -> UserProgress
    func loadCachedVocabulary() throws -> VocabularyCatalog?
    func saveCachedVocabulary(_ catalog: VocabularyCatalog) throws
    func commitTerminalSession(_ snapshot: SessionPersistence, completedAt: Date) throws -> UserProgress
}

@MainActor
final class PersistenceController {
    let container: NSPersistentContainer
    private(set) var loadError: Error?

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FastVocab", managedObjectModel: Self.makeModel())
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                self.loadError = error
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "StoredValue"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let key = NSAttributeDescription()
        key.name = "key"
        key.attributeType = .stringAttributeType
        key.isOptional = false

        let payload = NSAttributeDescription()
        payload.name = "payload"
        payload.attributeType = .binaryDataAttributeType
        payload.isOptional = false

        let updatedAt = NSAttributeDescription()
        updatedAt.name = "updatedAt"
        updatedAt.attributeType = .dateAttributeType
        updatedAt.isOptional = false

        entity.properties = [key, payload, updatedAt]
        entity.uniquenessConstraints = [["key"]]
        model.entities = [entity]
        return model
    }
}

@MainActor
final class CoreDataRepository: PersistenceRepository {
    private enum Key {
        static let session = "active-session"
        static let userProgress = "user-progress"
        static let vocabulary = "vocabulary-cache"
    }

    private let context: NSManagedObjectContext
    private let controller: PersistenceController
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(controller: PersistenceController) {
        self.controller = controller
        context = controller.container.viewContext
    }

    func loadSession() throws -> SessionPersistence? {
        try load(SessionPersistence.self, key: Key.session)
    }

    func saveSession(_ snapshot: SessionPersistence) throws {
        try save(snapshot, key: Key.session)
    }

    func deleteSession() throws {
        if let object = try fetch(key: Key.session) {
            context.delete(object)
            try saveContext()
        }
    }

    func loadUserProgress() throws -> UserProgress {
        try load(UserProgress.self, key: Key.userProgress) ?? UserProgress()
    }

    func loadCachedVocabulary() throws -> VocabularyCatalog? {
        try load(VocabularyCatalog.self, key: Key.vocabulary)
    }

    func saveCachedVocabulary(_ catalog: VocabularyCatalog) throws {
        try save(catalog, key: Key.vocabulary)
    }

    func commitTerminalSession(_ snapshot: SessionPersistence, completedAt: Date) throws -> UserProgress {
        guard snapshot.state == .completed || snapshot.state == .gameOver else {
            throw PersistenceError.invalidData
        }
        var progress = try loadUserProgress()
        guard !progress.lessonResults.contains(where: { $0.id == snapshot.sessionID }) else {
            try deleteSession()
            return progress
        }

        progress.accumulatedXP += snapshot.statistics.earnedXP
        progress.lessonResults.append(LessonResult(
            id: snapshot.sessionID,
            topicID: snapshot.topicID,
            status: snapshot.state,
            statistics: snapshot.statistics,
            completedAt: completedAt
        ))
        for (id, staged) in snapshot.vocabularyStatistics {
            var aggregate = progress.vocabularyStatistics[id]
                ?? VocabularyLearningStatistics(vocabularyID: id)
            aggregate.correctAnswers += staged.correctAnswers
            aggregate.wrongAnswers += staged.wrongAnswers
            progress.vocabularyStatistics[id] = aggregate
        }

        try upsert(progress, key: Key.userProgress)
        if let sessionObject = try fetch(key: Key.session) {
            context.delete(sessionObject)
        }
        try saveContext()
        return progress
    }

    private func load<Value: Decodable>(_ type: Value.Type, key: String) throws -> Value? {
        guard let object = try fetch(key: key),
              let payload = object.value(forKey: "payload") as? Data else { return nil }
        do {
            return try decoder.decode(type, from: payload)
        } catch {
            throw PersistenceError.invalidData
        }
    }

    private func save<Value: Encodable>(_ value: Value, key: String) throws {
        try upsert(value, key: key)
        try saveContext()
    }

    private func upsert<Value: Encodable>(_ value: Value, key: String) throws {
        let object = try fetch(key: key) ?? NSManagedObject(
            entity: context.persistentStoreCoordinator!.managedObjectModel.entitiesByName["StoredValue"]!,
            insertInto: context
        )
        object.setValue(key, forKey: "key")
        object.setValue(try encoder.encode(value), forKey: "payload")
        object.setValue(Date(), forKey: "updatedAt")
    }

    private func fetch(key: String) throws -> NSManagedObject? {
        guard controller.loadError == nil else { throw PersistenceError.saveFailed }
        let request = NSFetchRequest<NSManagedObject>(entityName: "StoredValue")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "key == %@", key)
        return try context.fetch(request).first
    }

    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw PersistenceError.saveFailed
        }
    }
}
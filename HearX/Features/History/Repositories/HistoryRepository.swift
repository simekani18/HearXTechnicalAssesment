//
//  HistoryRepository.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/07.
//

import Foundation

@MainActor
final class HistoryRepository: HistoryRepositoryProtocol {
    private let storageService: StorageServiceProtocol

    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
    }

    func fetchTestSessions() async throws -> [TestSession] {
        try await storageService.fetchTestSessions()
    }

    func deleteTestSession(id: UUID) async throws {
        try await storageService.deleteTestSession(id: id)
    }
}

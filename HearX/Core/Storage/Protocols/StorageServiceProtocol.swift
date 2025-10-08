//
//  StorageServiceProtocol.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

enum StorageError: LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case contextUnavailable

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save test session"
        case .fetchFailed:
            return "Failed to fetch test history"
        case .deleteFailed:
            return "Failed to delete test session"
        case .contextUnavailable:
            return "Storage system unavailable"
        }
    }
}

@MainActor
protocol StorageServiceProtocol {
    func saveTestSession(_ session: TestSession) async throws
    func fetchTestSessions() async throws -> [TestSession]
    func deleteTestSession(id: UUID) async throws
}

//
//  HistoryRepositoryProtocol.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/07.
//

import Foundation

@MainActor
protocol HistoryRepositoryProtocol {
    func fetchTestSessions() async throws -> [TestSession]
    func deleteTestSession(id: UUID) async throws
}

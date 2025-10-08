//
//  HistoryViewModel.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var sessions: [TestSession] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var selectedSession: TestSession?

    private let repository: HistoryRepositoryProtocol

    init(repository: HistoryRepositoryProtocol) {
        self.repository = repository
    }

    func loadSessions() async {
        isLoading = true
        errorMessage = nil

        do {
            sessions = try await repository.fetchTestSessions()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteSession(_ session: TestSession) async {
        do {
            try await repository.deleteTestSession(id: session.id)
            await loadSessions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectSession(_ session: TestSession) {
        selectedSession = session
    }

    func clearSelection() {
        selectedSession = nil
    }
}

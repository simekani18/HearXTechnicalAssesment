//
//  HistoryViewModelTests.swift
//  HearXTests
//
//  Created by Simekani Mabambe on 2025/10/08.
//

import Testing
import Foundation
@testable import HearX

@MainActor
struct HistoryViewModelTests {

    // MARK: - Initial State

    @Test("Initial state is correct")
    func testInitialState() {
        let viewModel = createViewModel()

        #expect(viewModel.sessions.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Load Sessions

    @Test("Load sessions populates sessions")
    func testLoadSessions() async {
        let (viewModel, repository) = createViewModelWithMocks()
        let session1 = createTestSession(score: 50)
        let session2 = createTestSession(score: 40)
        repository.sessions = [session1, session2]

        await viewModel.loadSessions()

        #expect(viewModel.sessions.count == 2)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Load sessions handles error")
    func testLoadSessionsError() async {
        let (viewModel, repository) = createViewModelWithMocks()
        repository.shouldThrowError = true

        await viewModel.loadSessions()

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Delete Session

    @Test("Delete session removes from list")
    func testDeleteSession() async {
        let (viewModel, repository) = createViewModelWithMocks()
        let session1 = createTestSession(score: 50)
        let session2 = createTestSession(score: 40)
        repository.sessions = [session1, session2]

        await viewModel.loadSessions()
        repository.sessions = [session2]
        await viewModel.deleteSession(session1)

        #expect(viewModel.sessions.count == 1)
    }

    // MARK: - Navigation

    @Test("Select session updates selectedSession")
    func testSelectSession() {
        let viewModel = createViewModel()
        let session = createTestSession(score: 50)

        viewModel.selectSession(session)

        #expect(viewModel.selectedSession?.id == session.id)
    }

    @Test("Clear selection resets selectedSession")
    func testClearSelection() {
        let viewModel = createViewModel()
        let session = createTestSession(score: 50)

        viewModel.selectSession(session)
        viewModel.clearSelection()

        #expect(viewModel.selectedSession == nil)
    }

    // MARK: - Helpers

    private func createViewModel() -> HistoryViewModel {
        let repository = MockHistoryRepository()
        return HistoryViewModel(repository: repository)
    }

    private func createViewModelWithMocks() -> (
        HistoryViewModel,
        MockHistoryRepository
    ) {
        let repository = MockHistoryRepository()
        let viewModel = HistoryViewModel(repository: repository)
        return (viewModel, repository)
    }

    private func createTestSession(score: Int) -> TestSession {
        let rounds = (0..<10).map { _ in
            StoredRound(
                difficulty: 5,
                tripletPlayed: "123",
                tripletAnswered: "123"
            )
        }
        return TestSession(
            id: UUID(),
            date: Date(),
            score: score,
            rounds: rounds
        )
    }
}

// MARK: - Mocks

final class MockHistoryRepository: HistoryRepositoryProtocol {
    var sessions: [TestSession] = []
    var shouldThrowError = false

    func fetchTestSessions() async throws -> [TestSession] {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: -1)
        }
        return sessions
    }

    func deleteTestSession(id: UUID) async throws {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: -1)
        }
        sessions.removeAll { $0.id == id }
    }
}

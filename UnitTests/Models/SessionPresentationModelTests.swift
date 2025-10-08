//
//  SessionPresentationModelTests.swift
//  HearXTests
//
//  Created by Simekani Mabambe on 2025/10/08.
//

import Testing
import Foundation
@testable import HearX

struct SessionPresentationModelTests {

    // MARK: - Statistics

    @Test("Correct count calculation")
    func testCorrectCount() {
        let rounds = [
            StoredRound(difficulty: 5, tripletPlayed: "123", tripletAnswered: "123"),
            StoredRound(difficulty: 5, tripletPlayed: "456", tripletAnswered: "999"),
            StoredRound(difficulty: 6, tripletPlayed: "789", tripletAnswered: "789")
        ]
        let session = TestSession(id: UUID(), date: Date(), score: 11, rounds: rounds)
        let model = SessionPresentationModel(session: session)

        #expect(model.correctCount == 2)
    }

    @Test("Accuracy calculation")
    func testAccuracy() {
        let rounds = [
            StoredRound(difficulty: 5, tripletPlayed: "123", tripletAnswered: "123"),
            StoredRound(difficulty: 5, tripletPlayed: "456", tripletAnswered: "456"),
            StoredRound(difficulty: 6, tripletPlayed: "789", tripletAnswered: "999"),
            StoredRound(difficulty: 6, tripletPlayed: "234", tripletAnswered: "999")
        ]
        let session = TestSession(id: UUID(), date: Date(), score: 10, rounds: rounds)
        let model = SessionPresentationModel(session: session)

        #expect(model.accuracy == 50)
    }

    @Test("Average difficulty calculation")
    func testAverageDifficulty() {
        let rounds = [
            StoredRound(difficulty: 5, tripletPlayed: "123", tripletAnswered: "123"),
            StoredRound(difficulty: 7, tripletPlayed: "456", tripletAnswered: "456"),
            StoredRound(difficulty: 9, tripletPlayed: "789", tripletAnswered: "789")
        ]
        let session = TestSession(id: UUID(), date: Date(), score: 21, rounds: rounds)
        let model = SessionPresentationModel(session: session)

        #expect(model.averageDifficulty == 7.0)
    }

    // MARK: - Performance Level

    @Test("Excellent performance level")
    func testExcellentPerformance() {
        let rounds = (0..<10).map { _ in
            StoredRound(difficulty: 5, tripletPlayed: "123", tripletAnswered: "123")
        }
        let session = TestSession(id: UUID(), date: Date(), score: 50, rounds: rounds)
        let model = SessionPresentationModel(session: session)

        #expect(model.performanceLevel == .excellent)
    }

    @Test("Good performance level")
    func testGoodPerformance() {
        let rounds = (0..<10).map { i in
            StoredRound(
                difficulty: 5,
                tripletPlayed: "123",
                tripletAnswered: i < 7 ? "123" : "999"
            )
        }
        let session = TestSession(id: UUID(), date: Date(), score: 35, rounds: rounds)
        let model = SessionPresentationModel(session: session)

        #expect(model.performanceLevel == .good)
    }
}

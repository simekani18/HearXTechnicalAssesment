//
//  TestSession.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

struct TestSession: Identifiable {
    let id: UUID
    let date: Date
    let score: Int
    let rounds: [StoredRound]

    init(id: UUID = UUID(), date: Date = Date(), score: Int, rounds: [StoredRound]) {
        self.id = id
        self.date = date
        self.score = score
        self.rounds = rounds
    }

    static func from(_ result: TestResult) -> TestSession {
        let rounds = result.rounds.map { roundResult in
            StoredRound(
                difficulty: roundResult.difficulty,
                tripletPlayed: roundResult.tripletPlayed,
                tripletAnswered: roundResult.tripletAnswered
            )
        }
        return TestSession(score: result.score, rounds: rounds)
    }
}

//
//  Round.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

struct Round: Identifiable, Sendable {
    let id: UUID
    let roundNumber: Int
    let difficulty: Int
    let triplet: String
    var userAnswer: String

    var isCorrect: Bool {
        triplet == userAnswer
    }

    var pointsAwarded: Int {
        isCorrect ? difficulty : 0
    }

    init(roundNumber: Int, difficulty: Int, triplet: String, userAnswer: String = "") {
        self.id = UUID()
        self.roundNumber = roundNumber
        self.difficulty = difficulty
        self.triplet = triplet
        self.userAnswer = userAnswer
    }

    func toRoundResult() -> RoundResult {
        RoundResult(
            difficulty: difficulty,
            tripletPlayed: triplet,
            tripletAnswered: userAnswer
        )
    }
}

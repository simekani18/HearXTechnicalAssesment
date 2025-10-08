//
//  StoredRound.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

struct StoredRound {
    let difficulty: Int
    let tripletPlayed: String
    let tripletAnswered: String

    var isCorrect: Bool {
        tripletPlayed == tripletAnswered
    }

    var pointsAwarded: Int {
        isCorrect ? difficulty : 0
    }

    init(difficulty: Int, tripletPlayed: String, tripletAnswered: String) {
        self.difficulty = difficulty
        self.tripletPlayed = tripletPlayed
        self.tripletAnswered = tripletAnswered
    }
}

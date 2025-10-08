//
//  RoundResult.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

struct RoundResult: Codable, Sendable {
    let difficulty: Int
    let tripletPlayed: String
    let tripletAnswered: String

    enum CodingKeys: String, CodingKey {
        case difficulty
        case tripletPlayed = "triplet_played"
        case tripletAnswered = "triplet_answered"
    }

    init(difficulty: Int, tripletPlayed: String, tripletAnswered: String) {
        self.difficulty = difficulty
        self.tripletPlayed = tripletPlayed
        self.tripletAnswered = tripletAnswered
    }
}

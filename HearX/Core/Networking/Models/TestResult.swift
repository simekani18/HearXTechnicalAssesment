//
//  TestResult.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

struct TestResult: Codable, Sendable {
    let score: Int
    let rounds: [RoundResult]

    init(score: Int, rounds: [RoundResult]) {
        self.score = score
        self.rounds = rounds
    }
}

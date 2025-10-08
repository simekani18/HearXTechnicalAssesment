//
//  SessionPresentationModel.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/07.
//

import SwiftUI

struct SessionPresentationModel {
    let session: TestSession

    // MARK: - Statistics

    var correctCount: Int {
        session.rounds.filter { $0.isCorrect }.count
    }

    var incorrectCount: Int {
        session.rounds.count - correctCount
    }

    var accuracy: Int {
        guard !session.rounds.isEmpty else { return 0 }
        return Int((Double(correctCount) / Double(session.rounds.count)) * 100)
    }

    var averageDifficulty: Double {
        let correctRounds = session.rounds.filter { $0.isCorrect }
        guard !correctRounds.isEmpty else { return 0.0 }
        let totalDifficulty = correctRounds.reduce(0) { $0 + $1.difficulty }
        return Double(totalDifficulty) / Double(correctRounds.count)
    }

    // MARK: - Performance Level

    enum PerformanceLevel {
        case excellent
        case good
        case needsPractice

        var label: String {
            switch self {
            case .excellent: return "Excellent"
            case .good: return "Good"
            case .needsPractice: return "Practice"
            }
        }

        var icon: String {
            switch self {
            case .excellent: return "star.fill"
            case .good: return "checkmark.circle.fill"
            case .needsPractice: return "arrow.up.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .excellent: return .green
            case .good: return .blue
            case .needsPractice: return .orange
            }
        }
    }

    var performanceLevel: PerformanceLevel {
        if accuracy >= 80 { return .excellent }
        if accuracy >= 60 { return .good }
        return .needsPractice
    }

    // MARK: - Round Details

    struct RoundPresentation: Identifiable {
        let id: Int
        let roundNumber: Int
        let round: StoredRound

        var isCorrect: Bool {
            round.isCorrect
        }

        var statusIcon: String {
            isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
        }

        var statusColor: Color {
            isCorrect ? .green : .red
        }

        var answerTextColor: Color {
            isCorrect ? .primary : .red
        }
    }

    var roundPresentations: [RoundPresentation] {
        session.rounds.enumerated().map { index, round in
            RoundPresentation(
                id: index,
                roundNumber: index + 1,
                round: round
            )
        }
    }
}

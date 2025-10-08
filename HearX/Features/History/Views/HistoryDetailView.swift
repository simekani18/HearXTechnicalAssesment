//
//  HistoryDetailView.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import SwiftUI

struct HistoryDetailView: View {
    let presentationModel: SessionPresentationModel
    @Environment(\.dismiss) private var dismiss

    init(session: TestSession) {
        self.presentationModel = SessionPresentationModel(session: session)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                scoreHeader

                Divider()

                roundsSection
            }
            .padding()
        }
        .navigationTitle("Test Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private var scoreHeader: some View {
        VStack(spacing: 12) {
            Text("\(presentationModel.correctCount)/10")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(.blue)

            Text("Correct Answers")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(presentationModel.session.date, style: .date)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(presentationModel.session.date, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                StatItem(
                    label: "Avg Difficulty",
                    value: String(format: "%.1f", presentationModel.averageDifficulty),
                    color: .orange
                )

                StatItem(
                    label: "Total Points",
                    value: "\(presentationModel.session.score)",
                    color: .green
                )

                StatItem(
                    label: "Accuracy",
                    value: "\(presentationModel.accuracy)%",
                    color: .blue
                )
            }
            .padding(.top, 8)
        }
    }

    private var roundsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Round by Round")
                .font(.headline)

            ForEach(presentationModel.roundPresentations) { roundPresentation in
                RoundDetailRow(roundPresentation: roundPresentation)
            }
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct RoundDetailRow: View {
    let roundPresentation: SessionPresentationModel.RoundPresentation

    var body: some View {
        HStack(spacing: 12) {
            Text("R\(roundPresentation.roundNumber)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Played:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(roundPresentation.round.tripletPlayed)
                        .font(.body)
                        .fontWeight(.medium)
                }

                HStack(spacing: 8) {
                    Text("Answered:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(roundPresentation.round.tripletAnswered)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(roundPresentation.answerTextColor)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: roundPresentation.statusIcon)
                    .foregroundStyle(roundPresentation.statusColor)

                Text("Diff: \(roundPresentation.round.difficulty)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if roundPresentation.isCorrect {
                    Text("+\(roundPresentation.round.pointsAwarded)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        HistoryDetailView(
            session: TestSession(
                score: 75,
                rounds: [
                    StoredRound(difficulty: 5, tripletPlayed: "123", tripletAnswered: "123"),
                    StoredRound(difficulty: 6, tripletPlayed: "456", tripletAnswered: "456"),
                    StoredRound(difficulty: 7, tripletPlayed: "789", tripletAnswered: "788")
                ]
            )
        )
    }
}

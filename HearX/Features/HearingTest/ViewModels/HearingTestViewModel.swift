//
//  HearingTestViewModel.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

@MainActor
final class HearingTestViewModel: ObservableObject {
    @Published private(set) var state: TestState = .idle
    @Published private(set) var currentRound: Int = 0
    @Published private(set) var currentDifficulty: Int = 5
    @Published var userInput: String = ""
    @Published var alertType: AlertType? = nil

    private var rounds: [Round] = []
    private var usedTriplets: Set<String> = []
    private var previousTriplet: String?

    private let repository: HearingTestRepositoryProtocol

    var totalRounds: Int { 10 }

    var isSubmitEnabled: Bool {
        userInput.count == 3 && state == .waitingForInput
    }

    var totalScore: Int {
        rounds.reduce(0) { $0 + $1.pointsAwarded }
    }

    var correctAnswers: Int {
        rounds.filter { $0.isCorrect }.count
    }

    var averageDifficulty: Double {
        let correctRounds = rounds.filter { $0.isCorrect }
        guard !correctRounds.isEmpty else { return 0.0 }
        let totalDifficulty = correctRounds.reduce(0) { $0 + $1.difficulty }
        return Double(totalDifficulty) / Double(correctRounds.count)
    }

    enum AlertType: Identifiable {
        case exitConfirmation
        case completion(correctAnswers: Int, totalRounds: Int, averageDifficulty: Double, totalPoints: Int)
        case error(message: String)

        var id: String {
            switch self {
            case .exitConfirmation: return "exit"
            case .completion: return "completion"
            case .error: return "error"
            }
        }
    }

    init(repository: HearingTestRepositoryProtocol) {
        self.repository = repository
    }

    func showExitConfirmation() {
        alertType = .exitConfirmation
    }

    func dismissAlert() {
        alertType = nil
    }

    func startTest() async {
        resetTest()

        do {
            try repository.configureAudio()
            await performCountdown(seconds: 3)
            await startNextRound()
        } catch {
            state = .error(message: error.localizedDescription)
        }
    }

    func submitAnswer() async {
        guard state == .waitingForInput, userInput.count == 3 else { return }

        state = .processingAnswer

        rounds[currentRound - 1].userAnswer = userInput
        let wasCorrect = rounds[currentRound - 1].isCorrect

        adjustDifficulty(wasCorrect: wasCorrect)

        userInput = ""

        if currentRound >= totalRounds {
            await completeTest()
        } else {
            await performCountdown(seconds: 2)
            await startNextRound()
        }
    }

    func exitTest() {
        repository.stopAudio()
        resetTest()
        state = .idle
    }

    func addDigit(_ digit: String) {
        guard userInput.count < 3,
              let digitInt = Int(digit),
              (1...9).contains(digitInt) else { return }
        userInput += digit
    }

    func deleteLastDigit() {
        guard !userInput.isEmpty else { return }
        userInput.removeLast()
    }

    private func resetTest() {
        currentRound = 0
        currentDifficulty = 5
        rounds = []
        usedTriplets = []
        previousTriplet = nil
        userInput = ""
        state = .idle
    }

    private func performCountdown(seconds: Int) async {
        for i in stride(from: seconds, through: 1, by: -1) {
            state = .countdown(secondsRemaining: i)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    private func startNextRound() async {
        currentRound += 1

        do {
            let triplet = try await repository.generateTriplet(
                previousTriplet: previousTriplet,
                usedTriplets: usedTriplets
            )

            usedTriplets.insert(triplet)
            previousTriplet = triplet

            let round = Round(
                roundNumber: currentRound,
                difficulty: currentDifficulty,
                triplet: triplet
            )
            rounds.append(round)
            state = .playingAudio

            try await repository.playTriplet(triplet, difficulty: currentDifficulty)

            state = .waitingForInput

        } catch {
            state = .error(message: "Test interrupted due to audio error. Please restart the test.")
        }
    }

    private func adjustDifficulty(wasCorrect: Bool) {
        if wasCorrect {
            currentDifficulty = min(currentDifficulty + 1, 10)
        } else {
            currentDifficulty = max(currentDifficulty - 1, 1)
        }
    }

    private func completeTest() async {
        state = .uploadingResults

        let result = TestResult(
            score: totalScore,
            rounds: rounds.map { $0.toRoundResult() }
        )

        do {
            try await repository.uploadTestResult(result)

            let session = TestSession.from(result)
            try? await repository.saveTestSession(session)

            state = .completed(score: totalScore)
            alertType = .completion(
                correctAnswers: correctAnswers,
                totalRounds: totalRounds,
                averageDifficulty: averageDifficulty,
                totalPoints: totalScore
            )
        } catch {
            let errorMessage = "Upload failed: \(error.localizedDescription)"
            state = .error(message: errorMessage)
            alertType = .error(message: errorMessage)
        }
    }
}

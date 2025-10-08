//
//  HearingTestViewModelTests.swift
//  HearXTests
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Testing
import Foundation
@testable import HearX

@MainActor
struct HearingTestViewModelTests {

    // MARK: - Initial State

    @Test("Initial state is idle")
    func testInitialState() async {
        let viewModel = createViewModel()

        #expect(viewModel.state == .idle)
        #expect(viewModel.currentRound == 0)
        #expect(viewModel.currentDifficulty == 5)
        #expect(viewModel.totalScore == 0)
    }

    // MARK: - Difficulty Adjustment

    @Test("Difficulty increases on correct answer")
    func testDifficultyIncrease() async {
        let (viewModel, repository) = createViewModelWithMocks()
        repository.tripletSequence = ["123", "456"]

        await viewModel.startTest()
        viewModel.userInput = "123"
        await viewModel.submitAnswer()

        #expect(viewModel.currentDifficulty == 6)
    }

    @Test("Difficulty decreases on incorrect answer")
    func testDifficultyDecrease() async {
        let (viewModel, repository) = createViewModelWithMocks()
        repository.tripletSequence = ["123", "456"]

        await viewModel.startTest()
        viewModel.userInput = "999"
        await viewModel.submitAnswer()

        #expect(viewModel.currentDifficulty == 4)
    }

    // MARK: - Score Calculation

    @Test("Score awards points for correct answers")
    func testScoreCalculation() async {
        let (viewModel, repository) = createViewModelWithMocks()
        repository.tripletSequence = ["123", "456", "789"]

        await viewModel.startTest()

        viewModel.userInput = "123"
        await viewModel.submitAnswer()
        await Task.yield()

        #expect(viewModel.totalScore == 5)

        viewModel.userInput = "456"
        await viewModel.submitAnswer()
        await Task.yield()

        #expect(viewModel.totalScore == 11)
    }

    @Test("No score for incorrect answers")
    func testIncorrectAnswerScore() async {
        let (viewModel, repository) = createViewModelWithMocks()
        repository.tripletSequence = Array(repeating: "123", count: 3)

        await viewModel.startTest()

        viewModel.userInput = "999"
        await viewModel.submitAnswer()
        await Task.yield()

        #expect(viewModel.totalScore == 0)
    }

    // MARK: - Test Flow

    @Test("Test completes after 10 rounds")
    func testCompletion() async {
        let (viewModel, repository) = createViewModelWithMocks()
        repository.tripletSequence = Array(repeating: "123", count: 10)

        await viewModel.startTest()

        for _ in 0..<10 {
            viewModel.userInput = "123"
            await viewModel.submitAnswer()
            await Task.yield()
        }

        if case .completed = viewModel.state {
        } else {
            Issue.record("Expected completed state")
        }
    }

    // MARK: - Input Validation

    @Test("Input limits to 3 digits")
    func testInputLimit() async {
        let viewModel = createViewModel()

        viewModel.addDigit("1")
        viewModel.addDigit("2")
        viewModel.addDigit("3")
        viewModel.addDigit("4")

        #expect(viewModel.userInput == "123")
    }

    @Test("Delete removes last digit")
    func testDeleteDigit() async {
        let viewModel = createViewModel()
        viewModel.userInput = "123"

        viewModel.deleteLastDigit()
        #expect(viewModel.userInput == "12")
    }

    // MARK: - Helpers

    private func createViewModel() -> HearingTestViewModel {
        let repository = MockHearingTestRepository()
        return HearingTestViewModel(repository: repository)
    }

    private func createViewModelWithMocks() -> (
        HearingTestViewModel,
        MockHearingTestRepository
    ) {
        let repository = MockHearingTestRepository()
        let viewModel = HearingTestViewModel(repository: repository)
        return (viewModel, repository)
    }
}

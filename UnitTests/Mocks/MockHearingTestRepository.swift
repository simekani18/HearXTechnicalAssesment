//
//  MockHearingTestRepository.swift
//  UnitTests
//
//  Created by Simekani Mabambe on 2025/10/07.
//

import Foundation
@testable import HearX

final class MockHearingTestRepository: HearingTestRepositoryProtocol {
    var tripletSequence: [String] = []
    var currentTripletIndex: Int = 0
    var shouldThrowError: Bool = false

    var configureAudioCalled: Bool = false
    var playTripletCalled: Bool = false
    var lastTripletPlayed: String?
    var lastDifficultyPlayed: Int?
    var playbackDelay: TimeInterval = 0.0

    var stopAudioCalled: Bool = false

    var uploadCalled: Bool = false
    var lastUploadedResult: TestResult?
    var uploadDelay: TimeInterval = 0.0

    var saveCalled: Bool = false
    var lastSavedSession: TestSession?

    func generateTriplet(previousTriplet: String?, usedTriplets: Set<String>) async throws -> String {
        guard currentTripletIndex < tripletSequence.count else {
            return "123"
        }
        let triplet = tripletSequence[currentTripletIndex]
        currentTripletIndex += 1
        return triplet
    }

    func playTriplet(_ triplet: String, difficulty: Int) async throws {
        playTripletCalled = true
        lastTripletPlayed = triplet
        lastDifficultyPlayed = difficulty

        if shouldThrowError {
            throw AudioError.audioSessionError(NSError(domain: "test", code: 1))
        }

        try await Task.sleep(nanoseconds: UInt64(playbackDelay * 1_000_000_000))
    }

    func configureAudio() throws {
        configureAudioCalled = true
        if shouldThrowError {
            throw AudioError.audioSessionError(NSError(domain: "test", code: 1))
        }
    }

    func stopAudio() {
        stopAudioCalled = true
    }

    func uploadTestResult(_ result: TestResult) async throws {
        uploadCalled = true
        lastUploadedResult = result

        if shouldThrowError {
            throw NetworkError.serverError(statusCode: 500)
        }

        try await Task.sleep(nanoseconds: UInt64(uploadDelay * 1_000_000_000))
    }

    func saveTestSession(_ session: TestSession) async throws {
        saveCalled = true
        lastSavedSession = session
    }
}

//
//  MockAudioService.swift
//  HearXTests
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation
@testable import HearX

final class MockAudioService: AudioServiceProtocol {
    var playTripletCalled: Bool = false
    var lastTriplet: String?
    var lastDifficulty: Int?
    var shouldThrowError: Bool = false
    var playbackDelay: TimeInterval = 0.001
    var configureAudioSessionCalled: Bool = false

    func playTriplet(_ triplet: String, difficulty: Int) async throws {
        playTripletCalled = true
        lastTriplet = triplet
        lastDifficulty = difficulty

        if shouldThrowError {
            throw AudioError.playbackFailed
        }

        try await Task.sleep(nanoseconds: UInt64(playbackDelay * 1_000_000_000))
    }

    func stopAudio() {
        // No-op for mock
    }

    func configureAudioSession() throws {
        configureAudioSessionCalled = true

        if shouldThrowError {
            throw AudioError.audioSessionError(NSError(domain: "test", code: -1))
        }
    }

    func reset() {
        playTripletCalled = false
        lastTriplet = nil
        lastDifficulty = nil
        configureAudioSessionCalled = false
    }
}

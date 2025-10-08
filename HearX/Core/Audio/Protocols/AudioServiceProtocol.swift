//
//  AudioServiceProtocol.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

enum AudioError: LocalizedError {
    case fileNotFound(String)
    case playbackFailed
    case audioSessionError(Error)
    case invalidDifficulty(Int)
    case invalidTriplet(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Audio file not found: \(filename)"
        case .playbackFailed:
            return "Unable to play audio. Please check volume and try again."
        case .audioSessionError(let error):
            return "Audio system error: \(error.localizedDescription)"
        case .invalidDifficulty(let level):
            return "Invalid difficulty level: \(level). Must be 1-10."
        case .invalidTriplet(let triplet):
            return "Invalid triplet format: \(triplet)"
        }
    }
}

@MainActor
protocol AudioServiceProtocol {
    func playTriplet(_ triplet: String, difficulty: Int) async throws
    func stopAudio()
    func configureAudioSession() throws
}

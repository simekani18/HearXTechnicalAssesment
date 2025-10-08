//
//  TestState.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

enum TestState: Equatable, Sendable {
    case idle
    case countdown(secondsRemaining: Int)
    case playingAudio
    case waitingForInput
    case processingAnswer
    case uploadingResults
    case completed(score: Int)
    case error(message: String)
}

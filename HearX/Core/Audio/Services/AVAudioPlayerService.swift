//
//  AVAudioPlayerService.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import AVFoundation

@MainActor
final class AVAudioPlayerService: NSObject, AudioServiceProtocol {
    private var noisePlayer: AVAudioPlayer?
    private var digitPlayers: [AVAudioPlayer] = []
    private let digitInterval: TimeInterval = 1.0
    private let noiseStopDelay: TimeInterval = 0.3

    func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            throw AudioError.audioSessionError(error)
        }
    }

    func playTriplet(_ triplet: String, difficulty: Int) async throws {
        guard (1...10).contains(difficulty) else {
            throw AudioError.invalidDifficulty(difficulty)
        }

        guard triplet.count == 3, triplet.allSatisfy({ $0.isNumber && $0 != "0" }) else {
            throw AudioError.invalidTriplet(triplet)
        }

        stopAudio()

        try await playTripletSequence(triplet, difficulty: difficulty)
    }

    func stopAudio() {
        noisePlayer?.stop()
        noisePlayer = nil

        digitPlayers.forEach { $0.stop() }
        digitPlayers.removeAll()
    }

    private func playTripletSequence(_ triplet: String, difficulty: Int) async throws {
        let noiseFileName = "noise_\(difficulty)"
        let tripletDigits = Array(triplet)

        guard let noiseURL = Bundle.main.url(forResource: noiseFileName, withExtension: "m4a") else {
            throw AudioError.fileNotFound("\(noiseFileName).m4a")
        }

        noisePlayer = try AVAudioPlayer(contentsOf: noiseURL)
        noisePlayer?.numberOfLoops = -1
        noisePlayer?.volume = 1.0
        noisePlayer?.prepareToPlay()
        noisePlayer?.play()

        try await Task.sleep(nanoseconds: UInt64(digitInterval * 1_000_000_000))

        for (index, digit) in tripletDigits.enumerated() {
            try await playDigit(String(digit), volume: 1.0)

            if index < tripletDigits.count - 1 {
                try await Task.sleep(nanoseconds: UInt64(digitInterval * 1_000_000_000))
            }
        }

        try await Task.sleep(nanoseconds: UInt64((digitInterval + noiseStopDelay) * 1_000_000_000))

        noisePlayer?.stop()
        noisePlayer = nil
    }

    private func playDigit(_ digit: String, volume: Float = 1.0) async throws {
        guard let digitURL = Bundle.main.url(forResource: digit, withExtension: "m4a") else {
            throw AudioError.fileNotFound("\(digit).m4a")
        }

        let digitPlayer = try AVAudioPlayer(contentsOf: digitURL)
        digitPlayer.volume = volume
        digitPlayer.prepareToPlay()
        digitPlayer.play()

        digitPlayers.append(digitPlayer)
    }
}

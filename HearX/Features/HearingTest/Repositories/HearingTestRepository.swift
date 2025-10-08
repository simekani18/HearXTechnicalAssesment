//
//  HearingTestRepository.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/07.
//

import Foundation

@MainActor
final class HearingTestRepository: HearingTestRepositoryProtocol {
    private let tripletGenerator: TripletGeneratorProtocol
    private let audioService: AudioServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let storageService: StorageServiceProtocol?

    init(
        tripletGenerator: TripletGeneratorProtocol,
        audioService: AudioServiceProtocol,
        networkService: NetworkServiceProtocol,
        storageService: StorageServiceProtocol?
    ) {
        self.tripletGenerator = tripletGenerator
        self.audioService = audioService
        self.networkService = networkService
        self.storageService = storageService
    }

    func generateTriplet(previousTriplet: String?, usedTriplets: Set<String>) async throws -> String {
        try tripletGenerator.generateTriplet(previousTriplet: previousTriplet, usedTriplets: usedTriplets)
    }

    func playTriplet(_ triplet: String, difficulty: Int) async throws {
        try await audioService.playTriplet(triplet, difficulty: difficulty)
    }

    func configureAudio() throws {
        try audioService.configureAudioSession()
    }

    func stopAudio() {
        audioService.stopAudio()
    }

    func uploadTestResult(_ result: TestResult) async throws {
        try await networkService.uploadTestResult(result)
    }

    func saveTestSession(_ session: TestSession) async throws {
        guard let storageService = storageService else { return }
        try await storageService.saveTestSession(session)
    }
}

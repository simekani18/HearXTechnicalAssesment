//
//  HearXApp.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/01.
//

import SwiftUI

@main
struct HearXApp: App {
    private let tripletGenerator = RandomTripletGenerator()
    private let audioService = AVAudioPlayerService()
    private let networkService = URLSessionNetworkService()
    private let storageService: StorageServiceProtocol?
    private let hearingTestRepository: HearingTestRepositoryProtocol
    private let historyRepository: HistoryRepositoryProtocol?

    init() {
        AudioAssetValidator.logValidationResults()

        storageService = try? CoreDataStorageService()

        hearingTestRepository = HearingTestRepository(
            tripletGenerator: tripletGenerator,
            audioService: audioService,
            networkService: networkService,
            storageService: storageService
        )

        if let storageService = storageService {
            historyRepository = HistoryRepository(storageService: storageService)
        } else {
            historyRepository = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: HearingTestViewModel(repository: hearingTestRepository),
                historyRepository: historyRepository
            )
        }
    }
}

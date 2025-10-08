//
//  HomeView.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HearingTestViewModel
    @State private var showingTest = false
    @State private var showingHistory = false

    let historyRepository: HistoryRepositoryProtocol?

    init(viewModel: HearingTestViewModel, historyRepository: HistoryRepositoryProtocol? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.historyRepository = historyRepository
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)

                    Text("HearX")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Digit in Noise Test")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 20) {
                    Button {
                        showingTest = true
                    } label: {
                        Text("Start Test")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)

                    if historyRepository != nil {
                        Button {
                            showingHistory = true
                        } label: {
                            Text("View Results")
                                .font(.headline)
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                }

                Spacer()
            }
            .navigationDestination(isPresented: $showingTest) {
                HearingTestView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showingHistory) {
                if let historyRepository = historyRepository {
                    HistoryListView(
                        viewModel: HistoryViewModel(repository: historyRepository)
                    )
                }
            }
        }
    }
}

#Preview {
    let repository = HearingTestRepository(
        tripletGenerator: RandomTripletGenerator(),
        audioService: AVAudioPlayerService(),
        networkService: URLSessionNetworkService(),
        storageService: nil
    )

    HomeView(
        viewModel: HearingTestViewModel(repository: repository),
        historyRepository: nil
    )
}

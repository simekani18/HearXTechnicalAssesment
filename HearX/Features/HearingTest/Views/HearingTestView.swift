//
//  HearingTestView.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import SwiftUI

struct HearingTestView: View {
    @ObservedObject var viewModel: HearingTestViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.currentRound > 0 {
                roundIndicator
            }

            Spacer()

            stateContent

            Spacer()

            if case .waitingForInput = viewModel.state {
                inputSection
                submitButton
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.showExitConfirmation()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Exit Test")
                    }
                }
            }
        }
        .alert(item: $viewModel.alertType) { alertType in
            switch alertType {
            case .exitConfirmation:
                return Alert(
                    title: Text("Exit Test?"),
                    message: Text("Your progress will be lost."),
                    primaryButton: .cancel(Text("Cancel")) {
                        viewModel.dismissAlert()
                    },
                    secondaryButton: .destructive(Text("Exit")) {
                        viewModel.exitTest()
                        dismiss()
                    }
                )
            case .completion(let correctAnswers, let totalRounds, let averageDifficulty, let totalPoints):
                let message = """
                Correct Answers: \(correctAnswers)/\(totalRounds)
                Average Difficulty: \(String(format: "%.1f", averageDifficulty))
                Total Points: \(totalPoints)
                """
                return Alert(
                    title: Text("Test Complete!"),
                    message: Text(message),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            case .error(let message):
                return Alert(
                    title: Text("Error"),
                    message: Text(message),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
        .task {
            await viewModel.startTest()
        }
    }

    private var roundIndicator: some View {
        Text("Round \(viewModel.currentRound) of \(viewModel.totalRounds)")
            .font(.headline)
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.state {
        case .idle:
            Text("Preparing test...")
                .font(.title2)

        case .countdown(let seconds):
            VStack(spacing: 20) {
                Text("\(seconds)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.blue)

                Text("Get ready...")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

        case .playingAudio:
            VStack(spacing: 20) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse)

                Text("Listen carefully")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

        case .waitingForInput:
            VStack(spacing: 16) {
                Text("What did you hear?")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text(viewModel.userInput.isEmpty ? "- - -" : viewModel.userInput)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(height: 60)
            }

        case .processingAnswer:
            ProgressView("Processing...")
                .font(.title2)

        case .uploadingResults:
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)

                Text("Uploading results...")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

        case .completed:
            EmptyView()

        case .error:
            EmptyView()
        }
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(1...9, id: \.self) { digit in
                    Button {
                        viewModel.addDigit(String(digit))
                    } label: {
                        Text(String(digit))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .frame(width: 70, height: 70)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.userInput.count >= 3)
                }
            }

            Button {
                viewModel.deleteLastDigit()
            } label: {
                Image(systemName: "delete.left.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .frame(width: 70, height: 70)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
            }
            .disabled(viewModel.userInput.isEmpty)
        }
    }

    private var submitButton: some View {
        Button {
            Task {
                await viewModel.submitAnswer()
            }
        } label: {
            Text("Submit")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isSubmitEnabled ? Color.blue : Color.gray)
                .cornerRadius(12)
        }
        .disabled(!viewModel.isSubmitEnabled)
        .padding(.horizontal, 40)
    }
}

#Preview {
    let repository = HearingTestRepository(
        tripletGenerator: RandomTripletGenerator(),
        audioService: AVAudioPlayerService(),
        networkService: URLSessionNetworkService(),
        storageService: nil
    )

    NavigationStack {
        HearingTestView(
            viewModel: HearingTestViewModel(repository: repository)
        )
    }
}

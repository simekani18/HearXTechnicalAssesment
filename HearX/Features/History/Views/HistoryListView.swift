//
//  HistoryListView.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import SwiftUI

struct HistoryListView: View {
    @StateObject private var viewModel: HistoryViewModel

    init(viewModel: HistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading test history...")
            } else if viewModel.sessions.isEmpty {
                emptyStateView
            } else {
                sessionListView
            }
        }
        .navigationTitle("Test History")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadSessions()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                // Error handled
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(item: $viewModel.selectedSession) { session in
            NavigationStack {
                HistoryDetailView(session: session)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Test History")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Complete a test to see your results here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var sessionListView: some View {
        List {
            ForEach(viewModel.sessions) { session in
                SessionRow(session: session)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectSession(session)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteSession(session)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct SessionRow: View {
    let presentationModel: SessionPresentationModel

    init(session: TestSession) {
        self.presentationModel = SessionPresentationModel(session: session)
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(presentationModel.correctCount)/10")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(presentationModel.session.date, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Avg Diff: \(String(format: "%.1f", presentationModel.averageDifficulty))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Label(
                    presentationModel.performanceLevel.label,
                    systemImage: presentationModel.performanceLevel.icon
                )
                .font(.caption)
                .foregroundStyle(presentationModel.performanceLevel.color)

                Text("\(presentationModel.session.score) pts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let storageService = try! CoreDataStorageService()
    let repository = HistoryRepository(storageService: storageService)

    NavigationStack {
        HistoryListView(
            viewModel: HistoryViewModel(repository: repository)
        )
    }
}

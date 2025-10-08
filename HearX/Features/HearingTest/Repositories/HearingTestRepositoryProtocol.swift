//
//  HearingTestRepositoryProtocol.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/07.
//

import Foundation

@MainActor
protocol HearingTestRepositoryProtocol {
    func generateTriplet(previousTriplet: String?, usedTriplets: Set<String>) async throws -> String
    func playTriplet(_ triplet: String, difficulty: Int) async throws
    func configureAudio() throws
    func stopAudio()
    func uploadTestResult(_ result: TestResult) async throws
    func saveTestSession(_ session: TestSession) async throws
}

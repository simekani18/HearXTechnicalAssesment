//
//  MockNetworkService.swift
//  HearXTests
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation
@testable import HearX

final class MockNetworkService: NetworkServiceProtocol {
    var uploadCalled: Bool = false
    var lastUploadedResult: TestResult?
    var shouldThrowError: Bool = false
    var uploadDelay: TimeInterval = 0.001
    var uploadAttempts: Int = 0

    func uploadTestResult(_ result: TestResult) async throws {
        uploadCalled = true
        uploadAttempts += 1
        lastUploadedResult = result

        if shouldThrowError {
            throw NetworkError.serverError(statusCode: 500)
        }

        try await Task.sleep(nanoseconds: UInt64(uploadDelay * 1_000_000_000))
    }

    func reset() {
        uploadCalled = false
        lastUploadedResult = nil
        uploadAttempts = 0
    }
}

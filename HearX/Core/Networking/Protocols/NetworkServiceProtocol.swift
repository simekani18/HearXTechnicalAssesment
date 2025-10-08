//
//  NetworkServiceProtocol.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

enum NetworkError: LocalizedError {
    case noInternetConnection
    case requestTimeout
    case serverError(statusCode: Int)
    case invalidResponse
    case encodingError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your network."
        case .requestTimeout:
            return "Request timed out. Please try again."
        case .serverError(let statusCode):
            return "Server error (code \(statusCode)). Please try again later."
        case .invalidResponse:
            return "Invalid server response."
        case .encodingError:
            return "Failed to encode test data."
        case .unknown(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

protocol NetworkServiceProtocol: Sendable {
   
    func uploadTestResult(_ result: TestResult) async throws
}

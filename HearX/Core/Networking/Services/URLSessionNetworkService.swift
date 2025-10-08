//
//  URLSessionNetworkService.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

final class URLSessionNetworkService: NetworkServiceProtocol {
    private let apiURL = URL(string: "https://enoqczf2j2pbadx.m.pipedream.net")!
    private let maxRetries = 3
    private let timeout: TimeInterval = 30

    func uploadTestResult(_ result: TestResult) async throws {
        var attempt = 0

        while attempt < maxRetries {
            do {
                try await performUpload(result, attempt: attempt + 1)
                return
            } catch {
                attempt += 1

                if attempt >= maxRetries {
                    throw error
                }

                let delay = pow(2.0, Double(attempt - 1))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    private func performUpload(_ result: TestResult, attempt: Int) async throws {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            request.httpBody = try encoder.encode(result)
        } catch {
            throw NetworkError.encodingError
        }

        let (_, response): (Data, URLResponse)

        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            if error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
                throw NetworkError.noInternetConnection
            } else if error.code == .timedOut {
                throw NetworkError.requestTimeout
            } else {
                throw NetworkError.unknown(error)
            }
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}

//
//  RandomTripletGenerator.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

final class RandomTripletGenerator: TripletGeneratorProtocol {
    private let maxAttempts = 1000

    func generateTriplet(
        previousTriplet: String?,
        usedTriplets: Set<String>
    ) throws -> String {
        var attempts = 0

        while attempts < maxAttempts {
            let candidate = generateRandomTriplet()

            guard !usedTriplets.contains(candidate) else {
                attempts += 1
                continue
            }

            if let previous = previousTriplet {
                guard isValidNextTriplet(candidate, after: previous) else {
                    attempts += 1
                    continue
                }
            }

            return candidate
        }

        throw TripletGeneratorError.maxAttemptsExceeded
    }

    private func generateRandomTriplet() -> String {
        let digits = (1...9).map { String($0) }
        var triplet = ""

        for _ in 0..<3 {
            let randomDigit = digits.randomElement()!
            triplet += randomDigit
        }

        return triplet
    }

    private func isValidNextTriplet(_ candidate: String, after previous: String) -> Bool {
        let candidateDigits = Array(candidate)
        let previousDigits = Array(previous)

        for i in 0..<3 {
            if candidateDigits[i] == previousDigits[i] {
                return false
            }
        }

        return true
    }
}

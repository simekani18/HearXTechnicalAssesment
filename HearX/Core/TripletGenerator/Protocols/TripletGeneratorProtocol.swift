//
//  TripletGeneratorProtocol.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation

enum TripletGeneratorError: LocalizedError {
    case impossibleConstraints
    case maxAttemptsExceeded

    var errorDescription: String? {
        switch self {
        case .impossibleConstraints:
            return "Unable to generate valid triplet with given constraints"
        case .maxAttemptsExceeded:
            return "Maximum generation attempts exceeded"
        }
    }
}

protocol TripletGeneratorProtocol: Sendable {
    func generateTriplet(
        previousTriplet: String?,
        usedTriplets: Set<String>
    ) throws -> String
}

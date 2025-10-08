//
//  MockTripletGenerator.swift
//  HearXTests
//
//  Created by Simekani Mabambe on 2025/10/06.
//

import Foundation
@testable import HearX

final class MockTripletGenerator: TripletGeneratorProtocol {
    var tripletSequence: [String] = []
    var currentIndex: Int = 0
    var shouldThrowError: Bool = false
    var generateTripletCalled: Bool = false
    var lastPreviousTriplet: String?
    var lastUsedTriplets: Set<String>?

    func generateTriplet(previousTriplet: String?, usedTriplets: Set<String>
    ) throws -> String {
        generateTripletCalled = true
        lastPreviousTriplet = previousTriplet
        lastUsedTriplets = usedTriplets

        if shouldThrowError {
            throw TripletGeneratorError.impossibleConstraints
        }

        guard currentIndex < tripletSequence.count else {
            return "123"
        }

        let triplet = tripletSequence[currentIndex]
        currentIndex += 1
        return triplet
    }

    func reset() {
        currentIndex = 0
        generateTripletCalled = false
        lastPreviousTriplet = nil
        lastUsedTriplets = nil
    }
}

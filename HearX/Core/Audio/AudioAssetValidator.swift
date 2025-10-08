//
//  AudioAssetValidator.swift
//  HearX
//
//  Created by Simekani Mabambe on 2025/10/07.
//

import Foundation

struct AudioAssetValidator {
    static func validateAllAudioAssets() -> [String] {
        var missingFiles: [String] = []

        for digit in 1...9 {
            if Bundle.main.url(forResource: "\(digit)", withExtension: "m4a") == nil {
                missingFiles.append("\(digit).m4a")
            }
        }

        for difficulty in 1...10 {
            if Bundle.main.url(forResource: "noise_\(difficulty)", withExtension: "m4a") == nil {
                missingFiles.append("noise_\(difficulty).m4a")
            }
        }

        return missingFiles
    }

    static func logValidationResults() {
        let missingFiles = validateAllAudioAssets()

        if missingFiles.isEmpty {
            print("All audio assets validated successfully")
        } else {
            print("Missing audio files:")
            for file in missingFiles {
                print("  - \(file)")
            }
        }
    }
}

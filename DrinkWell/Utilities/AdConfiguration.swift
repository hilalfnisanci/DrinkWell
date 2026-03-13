//
//  AdConfiguration.swift
//  DrinkWell
//

import Foundation

enum AdConfiguration {
    static var bannerAdUnitID: String? {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2435281174"
        #else
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: "GADBannerAdUnitID") as? String else {
            return nil
        }

        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
        #endif
    }
}

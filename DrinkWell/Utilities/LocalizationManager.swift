//
//  LocalizationManager.swift
//  DrinkWell
//
//  Created by Hilal on 21.03.2025.
//

import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()
    
    var currentBundle: Bundle = Bundle.main
    
    private init() {}
    
    func localizedString(for key: String) -> String {
        return NSLocalizedString(key, bundle: currentBundle, comment: "")
    }
}

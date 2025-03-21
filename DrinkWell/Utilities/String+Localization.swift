//
//  String+Localization.swift
//  DrinkWell
//
//  Created by Hilal on 21.03.2025.
//


import Foundation

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: [CVarArg]) -> String {
        let localizedFormat = LocalizationManager.shared.localizedString(for: self)
        return String(format: localizedFormat, locale: .current, arguments: arguments)
    }
}

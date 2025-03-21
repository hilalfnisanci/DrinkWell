//
//  DataController.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import Foundation
import SwiftData
import SwiftUI

// Single data controller for the entire application
@MainActor
class DataController: ObservableObject {
    // Singleton
    static let shared = DataController()
    
    // ModelContainer
    private let container: ModelContainer
    
    // Access to ModelContext
    var mainContext: ModelContext {
        container.mainContext
    }
    
    private init() {
        let schema = Schema([WaterIntake.self])
        
        do {
            // Use the application group directory
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.hilalNisanci.DrinkWell") else {
                throw NSError(
                    domain: "DataController",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "error_container_url_not_found".localized]
                )            
            }
            
            let storeURL = containerURL.appendingPathComponent("DrinkWell.store")
            
            let config = ModelConfiguration(
                schema: schema,
                url: storeURL,
                allowsSave: true,
                cloudKitDatabase: .none
            )
            
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("error_model_container_init".localized + ": \(error)")
        }
    }
    
    // Safe fetch operation
    func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        try mainContext.fetch(descriptor)
    }
    
    // Safe insert operation
    func insert<T>(_ model: T) where T: PersistentModel {
        mainContext.insert(model)
    }
    
    // Safe delete operation
    func delete<T>(_ model: T) where T: PersistentModel {
        mainContext.delete(model)
    }
    
    // Safe save operation
    func save() throws {
        try mainContext.save()
    }
}
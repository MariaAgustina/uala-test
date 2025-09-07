//
//  SmartCityApp.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import SwiftUI

@main
struct SmartCityApp: App {
    
    let coreDataStack: CoreDataStack = CoreDataStack()
    
    var body: some Scene {
        WindowGroup {
            MapView(coreDataStack: coreDataStack)
                .task {
                    do {
                        try await coreDataStack.load()
                        print("✅ CoreData loaded successfully at app launch")
                    } catch {
                        print("❌ Failed to load CoreData at app launch: \(error)")
                    }
                }
        }
    }
}

//
//  LearnCoreDataApp.swift
//  LearnCoreData
//
//  Created by Sachin Sharma on 26/09/23.
//

import SwiftUI

@main
struct LearnCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

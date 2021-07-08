//
//  NetworkDemistifierApp.swift
//  NetworkDemistifier
//
//  Created by Justin Allen on 7/8/21.
//

import SwiftUI

@main
struct NetworkDemistifierApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

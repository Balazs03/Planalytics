//
//  PlanalyticsApp.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 28..
//

import SwiftUI

@main
struct PlanalyticsApp: App {
    // Belépési pontnál létrehozom a coordinatort, hogy az legyen a root view
    @State private var coordinator = Coordinator()
    let persistentController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(container: persistentController)
                .environment(coordinator)
        }
    }
}

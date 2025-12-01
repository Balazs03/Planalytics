//
//  PlanalyticsApp.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 28..
//

import SwiftUI

@main
struct PlanalyticsApp: App {
    let persistentController = CoreDataManager.shared
    var body: some Scene {
        WindowGroup {
            MainPageView(vm: MainPageViewModel(container: persistentController))
        }
    }
}

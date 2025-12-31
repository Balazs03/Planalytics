//
//  Coordinator.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 19..
//

import Foundation
import SwiftUI
internal import CoreData

enum Page: Hashable {
    case goalsMain
    case goalDetail(Goal)
    case main
    case addGoal
    case addTransaction
    case allTransactions
}

enum Tab {
    case main
    case goals
}

enum Sheet: Hashable, Identifiable {
    var id: String {
        switch self {
        case .addMoney(let goal):
            return "addMoney_\(goal.id)"
        case .withdrawMoney(let goal):
            return "withdrawMoney_\(goal.id)"
        }
    }
    
    case addMoney(Goal)
    case withdrawMoney(Goal)
}

@Observable
class Coordinator {
    var mainPath = NavigationPath()
    var goalPath = NavigationPath()
    var sheet: Sheet?
    var selectedTab: Tab = .main
    
    var dataVersion: UUID = UUID()
        
    init() {
        setupCoreDataObserver()
    }
        
    private func setupCoreDataObserver() {
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil, // Bármelyik mentést figyeljük
            queue: .main
        ) { [weak self] _ in
            // Ha mentés történt, megváltoztatjuk az ID-t
            self?.dataVersion = UUID()
        }
    }
    
    func mainPush(_ page: Page) {
        mainPath.append(page)
    }
    
    func mainPop(){
        mainPath.removeLast()
    }
    
    func mainPopToRoot() {
        mainPath.removeLast(mainPath.count)
    }
    
    func goalPush(_ page: Page) {
        goalPath.append(page)
    }
    
    func goalPop(){
        goalPath.removeLast()
    }
    
    func goalPopToRoot() {
        goalPath.removeLast(goalPath.count)
    }
    
    func present(sheet: Sheet) {
        self.sheet = sheet
    }

    func dismissSheet() {
        self.sheet = nil
    }
}

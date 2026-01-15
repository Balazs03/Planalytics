//
//  GoalsMainPageViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 01..
//

import Foundation
internal import CoreData

@Observable
class GoalsMainViewModel {
    var goals : [Goal] = []
    var finishedGoalNumber: Int { return goals.filter { $0.isFinished }.count }
    let container: CoreDataManager
    var activeGoalNumber : Int { return goals.filter { !$0.isDeleted && !$0.isFinished }.count }
    var selectedFilter: GoalFilter = .all
    var filteredGoals: [Goal] {
        switch selectedFilter {
        case .all: return goals
        case .active: return goals.filter { !$0.isFinished }
        case .finished: return goals.filter { $0.isFinished }
        }
    }
    
    init(container: CoreDataManager) {
        self.container = container
        fetchGoals()
    }
    
    func fetchGoals() {
        goals = container.fetchGoals()
    }
}

enum GoalFilter: String, CaseIterable {
    case all = "Összes"
    case active = "Aktív"
    case finished = "Befejezett"
}

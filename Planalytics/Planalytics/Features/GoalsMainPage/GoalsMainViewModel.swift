//
//  GoalsMainPageViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 01..
//

import Foundation

@Observable
class GoalsMainViewModel {
    var goals : [Goal] = []
    var finishedGoalNumber: Int { return goals.filter { $0.isFinished }.count }
    let container: CoreDataManager
    
    init(container: CoreDataManager) {
        self.container = container
        fetchGoals()
    }
    
    func clearGoals() {
        goals = []
    }
    
    func fetchGoals() {
        goals = container.fetchGoals()
    }
}

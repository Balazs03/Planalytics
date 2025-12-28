//
//  GoalDetailPageViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import Foundation
internal import CoreData

@Observable
class GoalDetailViewModel {
    var goal: Goal
    let container :CoreDataManager
    var transBalance: Decimal = 0
    
    
    init(goal: Goal, container: CoreDataManager) {
        self.container = container
        self.goal = goal
    }
    
    func refreshData() {
        container.context.refresh(goal, mergeChanges: true)
        let balances = container.calculateTotalBalance()
        transBalance = balances[1]
    }
    
    func deleteGoal() {
        container.context.delete(goal)
        container.saveContext()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

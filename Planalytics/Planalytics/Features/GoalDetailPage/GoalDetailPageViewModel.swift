//
//  GoalDetailPageViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import Foundation
internal import CoreData

@Observable
class GoalDetailPageViewModel {
    var goal: Goal
    let container :CoreDataManager
    var transBalance: Decimal = 0
    
    init(goal: Goal, container: CoreDataManager) {
        self.container = container
        self.goal = goal
        refreshBalance()
    }
    
    func deleteGoal() {
        container.context.delete(goal)
        container.saveContext()
    }
    
    func refreshBalance() {
        let balances = container.calculateTotalBalance()
        transBalance = balances[1]
    }
}

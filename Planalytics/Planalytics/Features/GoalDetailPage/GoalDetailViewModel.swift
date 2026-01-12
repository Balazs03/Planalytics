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
        refreshData()
    }
    /*
    func addGoals() {
        let goal1Transaction = Transaction(context: container.context)
        goal1Transaction.amount = 1000.0
        goal1Transaction.name = "Teszt tranzakció első célhoz"
        var calendar1 = DateComponents()
        calendar1.year = 2025
        calendar1.month = 12
        calendar1.day = 31
        goal1Transaction.date = Calendar.current.date(from: calendar1)!
        goal1Transaction.transactionType = .expense
        goal1Transaction.transactionCategory = .saving
        goal.addToTransactions(goal1Transaction)
        goal.saving = ((goal.saving ?? 0) as Decimal) + (goal1Transaction.amount as Decimal) as NSDecimalNumber
        
        let goal2Transaction = Transaction(context: container.context)
        goal2Transaction.amount = 1000.0
        goal2Transaction.name = "Teszt tranzakció első célhoz"
        var calendar2 = DateComponents()
        calendar2.year = 2026
        calendar2.month = 01
        calendar2.day = 04
        goal2Transaction.date = Calendar.current.date(from: calendar1)!
        goal2Transaction.transactionType = .expense
        goal2Transaction.transactionCategory = .saving
        goal.addToTransactions(goal2Transaction)
        goal.saving = ((goal.saving ?? 0) as Decimal) + (goal2Transaction.amount as Decimal) as NSDecimalNumber
        
        container.saveContext()
    }
    */
    
    func refreshData() {
        container.context.refresh(goal, mergeChanges: true)
        let balances = container.calculateTotalBalance()
        transBalance = balances[1]
    }
    
    func deleteGoal() {
        if let saving = goal.saving as? Decimal, saving > 0 {
            let newTrans = Transaction(context: container.context)
            newTrans.amount = goal.saving!
            newTrans.name = "\(goal.name) nevű célra félretett megtakarítás"
            newTrans.date = Date()
            newTrans.transactionType = .income
        }
        container.context.delete(goal)
        container.saveContext()
    }
}

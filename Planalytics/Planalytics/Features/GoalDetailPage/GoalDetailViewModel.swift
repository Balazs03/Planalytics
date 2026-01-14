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
        let transactionsData: [(amount: Double, type: TransactionType, day: Int, month: Int, year: Int, name: String)] = [
            (5000.0, .expense, 5, 11, 2025, "Szerviz költség"),
            (2500.0, .expense, 12, 12, 2025, "Extra kiadás"),
            (1000.0, .income, 20, 1, 2026, "Havi megtakarítás"),
            (10000.0, .expense, 1, 2, 2026, "Februári számlák"),
            (3000.0, .expense, 15, 2, 2026, "Ajándék vásárlás"),
            (15000.0, .expense, 2, 3, 2026, "Márciusi számlák"),
            (5000.0, .income, 25, 3, 2026, "Névnapi ajándék"),
            (8000.0, .expense, 5, 4, 2026, "Áprilisi részlet"),
            (12000.0, .expense, 1, 5, 2026, "Váratlan kiadás"),
            (20000.0, .income, 15, 6, 2026, "Féléves bónusz")
        ]

        for (_, data) in transactionsData.enumerated() {
            let transaction = Transaction(context: container.context)
            transaction.amount = NSDecimalNumber(value: data.amount)
            transaction.name = data.name
            transaction.transactionType = data.type
            if data.type == .expense {
                transaction.transactionCategory = .saving
            }
            
            var components = DateComponents()
            components.year = data.year
            components.month = data.month
            components.day = data.day
            transaction.date = Calendar.current.date(from: components)!
            
            self.goal.addToTransactions(transaction)
            
            // Egyenleg frissítése a típus alapján
            let currentSaving = (self.goal.saving ?? 0) as Decimal
            if data.type == .expense {
                self.goal.saving = (currentSaving + Decimal(data.amount)) as NSDecimalNumber
            } else {
                self.goal.saving = (currentSaving - Decimal(data.amount)) as NSDecimalNumber
            }
        }
        
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

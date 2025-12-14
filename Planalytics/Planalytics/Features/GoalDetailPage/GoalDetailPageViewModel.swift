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
    let container = CoreDataManager.shared
    var transBalance: Decimal = 0
    var errorMessage: String?
    
    init(goal: Goal) {
        self.goal = goal
        refreshBalance()
    }
    
    func refreshBalance() {
        let balances = container.calculateTotalBalance()
        transBalance = balances[1]
    }
    
    func addBalancePossible(amount: Decimal) -> Bool {
        if amount <= transBalance {
            return true
        }
        errorMessage = "Nincs elegendő pénz a költségköltségből!"
        return false
    }
    
    func addBalance(amount: Decimal) -> Bool {
        let newTransaction = Transaction(context: container.context)
        newTransaction.amount = -amount as NSDecimalNumber
        newTransaction.date = Date()
        newTransaction.name = "Megtakarítás feltöltése a következő célra: \(goal.name)"
        newTransaction.transactionCategory = .saving
        newTransaction.transactionType = .expense
        
        goal.amount = (goal.amount as Decimal) + amount as NSDecimalNumber
        container.saveContext()
        refreshBalance()
        return true
    }
    
    func withdrawBalancePossible(amount: Decimal) -> Bool {
        if amount <= goal.amount as Decimal {
            return true
        }
        errorMessage = "Nincs elegendő pénz a költségköltségből!"
        return false
    }
    
    func withdrawBalance(amount: Decimal) -> Bool {

        let newTransaction = Transaction(context: container.context)
        newTransaction.amount = amount as NSDecimalNumber
        newTransaction.date = Date()
        newTransaction.name = "Utalás \(goal.name) célból"
        newTransaction.transactionType = .income
        
        goal.amount = (goal.amount as Decimal) - amount as NSDecimalNumber
        container.saveContext()
        return true
    }
}

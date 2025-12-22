//
//  AddMoneySheetViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 22..
//

import Foundation
internal import CoreData

@Observable
class AddMoneySheetViewModel {
    private var container: CoreDataManager
    var goal: Goal
    var amount: Decimal = 0
    var errorMessage: String?
    var transBalance: Decimal = 0
    
    init(container: CoreDataManager, goal: Goal) {
        self.container = container
        self.goal = goal
        transBalance = container.calculateTotalBalance()[1]
    }
    
    func addBalancePossible(amount: Decimal) -> Bool {
        if amount <= transBalance {
            return true
        }
        errorMessage = "Nincs elegendő pénz a költségköltségből!"
        return false
    }
    
    func addBalance(amount: Decimal) {
        let newTransaction = Transaction(context: container.context)
        newTransaction.amount = -amount as NSDecimalNumber
        newTransaction.date = Date()
        newTransaction.name = "Megtakarítás feltöltése a következő célra: \(goal.name)"
        newTransaction.transactionCategory = .saving
        newTransaction.transactionType = .expense
        
        goal.amount = (goal.amount as Decimal) + amount as NSDecimalNumber
        container.saveContext()
    }
}

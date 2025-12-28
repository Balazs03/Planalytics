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
    let container: CoreDataManager
    var goal: Goal
    var amount: Decimal = 0
    var errorMessage: String?
    var transBalance: Decimal = 0
    
    init(container: CoreDataManager, goal: Goal) {
        self.container = container
        self.goal = goal
        transBalance = container.calculateTotalBalance()[1]
    }
    
    func addBalancePossible() -> Bool {
        if amount <= transBalance {
            errorMessage = nil
            return true
        }
        errorMessage = "Nincs elegendő pénz a számlán!"
        return false
    }
    
    func addBalance() {
        let newTransaction = Transaction(context: container.context)
        newTransaction.amount = self.amount as NSDecimalNumber
        newTransaction.date = Date()
        newTransaction.name = "Megtakarítás feltöltése a következő célra: \(goal.name)"
        newTransaction.transactionCategory = .saving
        newTransaction.transactionType = .expense
        errorMessage = nil
        
        goal.saving = (goal.saving ?? 0) as Decimal + amount as NSDecimalNumber
        container.saveContext()
    }
}

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
    var amount: Decimal?
    var finishedMessage: String?
    var transBalance: Decimal

    init(container: CoreDataManager, goal: Goal) {
        self.container = container
        self.goal = goal
        self.transBalance = container.calculateTotalBalance()[1]
    }
    
    func addBalance() {
        guard let amount else { return }
        let newTransaction = Transaction(context: container.context)
        newTransaction.amount = amount as NSDecimalNumber
        newTransaction.date = Date()
        newTransaction.name = "Megtakarítás feltöltése a következő célra: \(goal.name)"
        newTransaction.transactionCategory = .saving
        newTransaction.transactionType = .expense
        newTransaction.goal = goal // ezzel az inverz kapcsolat miatt belerakom a transactions nssetbe
        // Másik megoldás a generált addTransaction függvénnyel
        newTransaction.transactionCategory = .saving
        
        goal.saving = (goal.saving ?? 0) as Decimal + amount as NSDecimalNumber
        container.saveContext()
    }
}

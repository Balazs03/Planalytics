//
//  WithdrawMoneySheetViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 22..
//

import Foundation
internal import CoreData

@Observable
class WithdrawMoneySheetViewModel {
    private let container: CoreDataManager
    var goal: Goal
    var errorMessage: String?
    var amount: Decimal = 0
    
    init(container: CoreDataManager, goal: Goal) {
        self.container = container
        self.goal = goal
    }
    
    func withdrawBalancePossible(amount: Decimal) -> Bool {
        if amount <= goal.amount as Decimal {
            return true
        }
        errorMessage = "Nincs elegendő pénz a költségköltségből!"
        return false
    }
    
    func withdrawBalance(amount: Decimal) {

        let newTransaction = Transaction(context: container.context)
        newTransaction.amount = amount as NSDecimalNumber
        newTransaction.date = Date()
        newTransaction.name = "Utalás \(goal.name) célból"
        newTransaction.transactionType = .income
        
        goal.amount = (goal.amount as Decimal) - amount as NSDecimalNumber
        container.saveContext()
    }
}

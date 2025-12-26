//
//  AddTransactionViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import Foundation
internal import CoreData

@Observable
class AddTransactionPageViewModel {
    let container: CoreDataManager
    var name : String = ""
    var amount: Decimal = 0
    var transactionType: TransactionType = .income
    var transactionCategory: TransactionCategory?
    
    init(container: CoreDataManager) {
        self.container = container
    }
    
    func saveTransaction() {
        let transaction = Transaction(context: container.context)
        if transactionType == . income && name.isEmpty {
            transaction.name = "Névtelen bevétel"
        }
        transaction.amount = amount as NSDecimalNumber
        transaction.transactionType = transactionType
        transaction.date = Date()
        
        if transactionType == .expense {
            transaction.transactionCategory = transactionCategory
        }
        
        container.saveContext()
    }
}

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
    
    func saveTransaction(name: String, amount: Decimal, type: TransactionType, category: TransactionCategory?) {
        let transaction = Transaction(context: container.context)
        transaction.name = name
        transaction.amount = amount as NSDecimalNumber
        transaction.transactionType = type
        transaction.transactionCategory = category
        
        container.saveContext()
    }
}

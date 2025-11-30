//
//  TransactionsListViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import Foundation

@Observable
class TransactionsListViewModel {
    let container: CoreDataManager
    var transactions : [Transaction] = []
    var sum: Decimal {
        return transactions.reduce(0) { $0 + ($1.amount as Decimal) }
    }
    
    init(container: CoreDataManager) {
        self.container = container
        loadTransactions()
    }
    
    func loadTransactions() {
        transactions = container.fetchTransactions(year: nil, month: nil)
    }
}

//
//  TransactionsListViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import Foundation

@Observable
class TransactionMainViewModel {
    let container: CoreDataManager
    var transactions : [Transaction]
    var totalBalance: Decimal
    var goalBalance: Decimal
    var transBalance: Decimal
    
    init(container: CoreDataManager) {
        self.container = container
        transactions = container.fetchTransactions(year: nil, month: nil)
        let balances = container.calculateTotalBalance()
        totalBalance = balances[0]
        transBalance = balances[1]
        goalBalance = balances[2]
    }
    
    func refreshData() {
        transactions = container.fetchTransactions(year: nil, month: nil)
        let balances = container.calculateTotalBalance()
        totalBalance = balances[0]
        transBalance = balances[1]
        goalBalance = balances[2]
    }
}

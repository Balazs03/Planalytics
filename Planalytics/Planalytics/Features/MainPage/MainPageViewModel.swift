//
//  TransactionsListViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import Foundation

@Observable
class MainPageViewModel {
    let container: CoreDataManager
    var transactions : [Transaction] = []
    var totalBalance: Decimal = 0
    var goalBalance: Decimal = 0
    var transBalance: Decimal = 0
    
    init(container: CoreDataManager) {
        self.container = container
        loadTransactions()
        let balances = container.calculateTotalBalance()
        totalBalance = balances[0]
        transBalance = balances[1]
        goalBalance = balances[2]
    }
    
    func loadTransactions() {
        transactions = container.fetchTransactions(year: nil, month: nil)
    }
}

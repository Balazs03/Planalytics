//
//  TransactionStatisticsViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 12..
//

import Foundation

@Observable
class TransactionStatisticsViewModel {
    let container: CoreDataManager
    let yearSelector: DateComponents
    let monthSelector: DateComponents
    var transactions: [Transaction]
    var expenses: [Transaction]
    var incomes: [Transaction]
    
    init(container: CoreDataManager) {
        self.container = container
        monthSelector = Calendar.current.dateComponents([.month], from: Date())
        yearSelector = Calendar.current.dateComponents([.year], from: Date())
        let fetchedTransactions = container.fetchTransactions(year: yearSelector.year, month: monthSelector.month)
        transactions = fetchedTransactions
        incomes = fetchedTransactions.filter { $0.transactionType == .income }
        expenses = fetchedTransactions.filter { $0.transactionType == .expense }
    }
    
    func refreshData() {
        self.transactions = container.fetchTransactions(year: yearSelector.year, month: monthSelector.month)
        incomes = transactions.filter { $0.transactionType == .income }
        expenses = transactions.filter { $0.transactionType == .expense }
    }
}

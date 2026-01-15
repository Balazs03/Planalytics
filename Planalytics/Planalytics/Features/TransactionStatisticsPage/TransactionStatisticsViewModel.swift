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
    var transactions: [Transaction]
    var expenses: [Transaction]
    var incomes: [Transaction]
    var selectedDate: Date = Date()
    
    var groupedTransactions: [(category: TransactionCategory, amount: Decimal)] {
        let groupedDict = Dictionary(grouping: expenses, by: \.categoryWrapper)
        
        let result = groupedDict.map { (category, transactions) in
            var sum: Decimal = 0
            
            for transaction in transactions {
                sum += transaction.amount.decimalValue
            }
            return (category: category, amount: sum)
        }
        
        return result.sorted(by: { $0.amount > $1.amount })
    }
    
    var totalExpenses: Decimal {
        expenses.reduce(0) { $0 + $1.amount.decimalValue }
    }
    
    var totalIncomes: Decimal {
        incomes.reduce(0) { $0 + $1.amount.decimalValue }
    }
    
    var balance: Bool {
        return (totalIncomes - totalExpenses) > 0
    }
    
    init(container: CoreDataManager) {
        self.container = container
        let fetchedTransactions = container.fetchTransactions(year: nil, month: nil)
        transactions = fetchedTransactions
        incomes = fetchedTransactions.filter { $0.transactionType == .income }
        expenses = fetchedTransactions.filter { $0.transactionType == .expense }
    }
    
    func refreshData() {
        let dateComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        let yearSelector = dateComponents.year
        let monthSelector = dateComponents.month
        self.transactions = container.fetchTransactions(year: yearSelector, month: monthSelector)
        incomes = transactions.filter { $0.transactionType == .income }
        expenses = transactions.filter { $0.transactionType == .expense }
    }
}

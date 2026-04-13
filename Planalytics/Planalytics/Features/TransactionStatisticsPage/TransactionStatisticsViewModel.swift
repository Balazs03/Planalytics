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
    var selectedYear: Int
    var selectedMonth: Int
    var firstTransactionYear: Int
    
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
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let fetchedTransactions = container.fetchTransactions(year: currentYear, month: currentMonth)
        
        self.container = container
        self.selectedYear = currentYear
        self.selectedMonth = currentMonth
        self.transactions = fetchedTransactions
        if let firstTransactionDate = container.fetchOldestTransactionDate() {
            self.firstTransactionYear = Calendar.current.component(.year, from: firstTransactionDate)
        } else {
            self.firstTransactionYear = currentYear
        }
        
        incomes = fetchedTransactions.filter { $0.transactionType == .income && $0.isRecurrent == false }
        expenses = fetchedTransactions.filter { $0.transactionType == .expense && $0.isRecurrent == false }
    }
    
    func refreshData() {
        transactions = container.fetchTransactions(year: selectedYear, month: selectedMonth)
        incomes = transactions.filter { $0.transactionType == .income && $0.isRecurrent == false }
        expenses = transactions.filter { $0.transactionType == .expense && $0.isRecurrent == false }
    }
}

//
//  AllTransactionViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 31..
//

import SwiftUI

@Observable
class AllTransactionsViewModel {
    let container: CoreDataManager
    var transactions: [Transaction] = []
    
    init(container: CoreDataManager) {
        self.container = container
        fetchTransactions(year: nil, month: nil)
    }
    
    func fetchTransactions(year: Int?, month: Int?) {
        transactions = container.fetchTransactions(year: year, month: month)
    }
}

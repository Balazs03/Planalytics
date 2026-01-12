//
//  TransactionsChart.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 12..
//

import SwiftUI
import Charts

struct TransactionsChart: View {
    let expenses: [Transaction]
    
    var allCategoryTitles: [String] {
        expenses.map(\.categoryWrapper.title)
    }
    
    var allCategoryColors: [Color] {
        expenses.map(\.categoryWrapper.diagramColor)
    }
    
    var body: some View {
        Chart {
            ForEach(expenses) { expense in
                let category = expense.categoryWrapper
                SectorMark(angle: .value("Kiadáspok", expense.amount.decimalValue), angularInset: 2)
                    .foregroundStyle(by: .value("Kategória", category.title))
            }
        }
        .chartForegroundStyleScale(domain: allCategoryTitles, range: allCategoryColors)
    }
}

#Preview {
    let mockManager = CoreDataManager.transactionListPreview()
    TransactionsChart(expenses: mockManager.fetchTransactions(year: nil, month: nil))
}


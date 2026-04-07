//
//  TransactionsChart.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 12..
//

import SwiftUI
import Charts

struct TransactionsChart: View {
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    let groupedTransactions: [(category: TransactionCategory, amount: Decimal)]
    let totalExpenses: Decimal
    
    var categoryTitles: [String] {
        groupedTransactions.map { appLanguage == "hu" ? $0.category.titleHU : $0.category.titleEN }
    }
    
    var categoryColors: [Color] {
        groupedTransactions.map { $0.category.diagramColor }
    }
    
    var body: some View {
        Chart {
            ForEach(groupedTransactions, id: \.category) { item in
                SectorMark(angle: .value("Kiadások", item.amount), innerRadius: .ratio(0.5), angularInset: 2)
                    .foregroundStyle(by: .value("Kategória", appLanguage == "hu" ? item.category.titleHU : item.category.titleEN))
                    .cornerRadius(10)
            }
        }
        .chartForegroundStyleScale(domain: categoryTitles, range: categoryColors)
        .frame(height: 250)
    }
}

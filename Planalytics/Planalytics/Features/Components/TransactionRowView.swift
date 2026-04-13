//
//  TransactionRowView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 31..
//

import SwiftUI

struct TransactionRowView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    @ObservedObject var transaction: Transaction

    var body: some View {
        HStack {
            Text(transaction.name ?? "Névtelen")
            if transaction.isRecurrent {
                
                VStack(alignment: .leading) {
                    Image(systemName: "repeat.circle.fill")
                    
                    if let nextDate = transaction.recurrenceStartDate {
                        let dateTitle = appLanguage == "hu" ? "Következő dátum:" : "Next date:"
                        
                        Text("\(dateTitle) \(nextDate.formatted(date: .numeric, time: .omitted))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            if transaction.transactionType == .income {
                Text("+\(transaction.amount.doubleValue.formatted()) Ft")
                    .foregroundStyle(.green)
            } else {
                if let category = transaction.transactionCategory {
                    Image(systemName: category.iconName)
                        .foregroundStyle(category.diagramColor)
                    
                    Text(appLanguage == "hu" ? category.titleHU : category.titleEN)
                        .foregroundStyle(.secondary)
                }
                      
                Text("-\(transaction.amount.doubleValue.formatted()) Ft")
                    .foregroundStyle(.red)
            }
        }
    }
}

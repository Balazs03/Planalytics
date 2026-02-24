//
//  TransactionRowView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 31..
//

import SwiftUI

struct TransactionRowView: View {
    @ObservedObject var transaction: Transaction

    var body: some View {
        HStack {
            Text(transaction.name ?? "Névtelen")
            if transaction.isRecurrent {
                Image(systemName: "repeat.circle.fill")
            }
            
            Spacer()
            if transaction.transactionType == .income {
                Text("+\(transaction.amount.doubleValue.formatted()) Ft")
                    .foregroundStyle(.green)
            } else {
                if let category = transaction.transactionCategory {
                    Image(systemName: transaction.transactionCategory?.iconName ?? "")
                        .foregroundStyle(category.diagramColor)
                    
                    Text(category.title)
                }
                      
                Text("-\(transaction.amount.doubleValue.formatted()) Ft")
                    .foregroundStyle(.red)
            }
        }
        .fontDesign(.rounded)
        .foregroundStyle(Color.appText)
    }
}

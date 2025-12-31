//
//  TransactionRowView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 31..
//

import SwiftUI

struct TransactionRowView: View {
    @ObservedObject var transaction: Transaction // Kulcsfontosságú a frissítéshez!

    var body: some View {
        HStack {
            // Ikon a kategória alapján (opcionális logika)
            Image(systemName: "circle.fill") 
                .font(.caption)
                .foregroundColor(transaction.transactionType == .income ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(transaction.name ?? "Névtelen")
                    .font(.headline)
                Text(transaction.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.amount) Ft")
                .bold()
                .foregroundColor(transaction.transactionType == .income ? .green : .primary)
        }
    }
}

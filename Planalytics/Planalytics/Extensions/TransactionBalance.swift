//
//  TransactionBalance.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 08. 11..
//

import Foundation

extension Collection where Element == Transaction {
    var totalBalance: Decimal {
        var sum = 0 as Decimal
        
        for transaction in self {
            
            if transaction.isRecurrent, let startDate = transaction.recurrenceStartDate, startDate > Date() {
                continue
            } else {
                if transaction.transactionType == .income {
                    sum += transaction.amount as Decimal
                } else {
                    sum -= transaction.amount as Decimal
                }
            }
        }
        
        return sum
    }
}

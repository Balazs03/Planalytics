//
//  TransactionStatisticsView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 12..
//

import SwiftUI

struct TransactionStatisticsView: View {
    @State private var vm: TransactionStatisticsViewModel
    @Environment(Coordinator.self) private var coordinator

    init(vm: TransactionStatisticsViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if !vm.transactions.isEmpty {
                    TransactionsChart(expenses: vm.expenses)
                }
            }
        }
    }
}

#Preview {
    let mockManager = CoreDataManager.transactionListPreview()
    let vm = TransactionStatisticsViewModel(container: mockManager)
    TransactionStatisticsView(vm: vm)
        .environment(Coordinator())
}

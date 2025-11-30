//
//  TransactionsListView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI

struct TransactionsListView: View {
    @State private var vm: TransactionsListViewModel
    
    init(vm: TransactionsListViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            Text("Egyenleg HUF")
            Text("\(vm.sum.formatted()) Ft")
                .fontWeight(.bold)
                .font(.system(size: 48))
            Spacer()
            if vm.transactions.isEmpty {
                Text("Nincs megjeleníthető adat.")
            } else {
                List {
                    ForEach(vm.transactions.prefix(3)) { transaction in
                        HStack {
                            Text(transaction.name ?? "Névtelen")
                            Spacer()
                            
                            switch (transaction.transactionType) {
                            case .income:
                                Text("+\(transaction.amount) Ft")
                            case .expense:
                                Text("-\(transaction.amount) Ft")
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button("Összes") {
                            
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    // memóriába mentő manager
    let mockManager = CoreDataManager.listPreview()
    let vm = TransactionsListViewModel(
        container: mockManager
    )
    TransactionsListView(vm: vm)
}

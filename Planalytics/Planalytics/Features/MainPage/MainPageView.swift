//
//  TransactionsListView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI

struct MainPageView: View {
    @State private var vm: MainPageViewModel
    
    init(vm: MainPageViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Egyenleg HUF")
                Text("\(vm.transBalance.formatted()) Ft")
                    .fontWeight(.bold)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.default, value: vm.transBalance)
            }
            
            HStack {
                Button("Hozzáadás") {
                    
                }
            }
                Spacer()
                if vm.transactions.isEmpty {
                    Text("Nincs megjeleníthető tranzakció")
                } else {
                    List {
                        ForEach(vm.transactions.prefix(3)) { transaction in
                            HStack {
                                VStack(alignment: .leading){
                                    
                                    Text(transaction.name ?? "Névtelen")
                                    Text(transaction.date, style: .date)
                                }
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
    let mockManager = CoreDataManager.transactionListPreview()
    let vm = MainPageViewModel(
        container: mockManager
    )
    MainPageView(vm: vm)
}

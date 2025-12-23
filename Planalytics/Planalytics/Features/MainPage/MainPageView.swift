//
//  TransactionsListView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI

struct MainPageView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: MainPageViewModel
    
    init(vm: MainPageViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Egyenleg HUF")
                HStack {
                    Text("\(vm.transBalance.formatted()) Ft")
                        .fontWeight(.bold)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.default, value: vm.transBalance)
                    
                    if vm.transBalance < 0 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.largeTitle)
                    }
                }
            }
            
            HStack {
                Button("Hozzáadás") {
                    coordinator.mainPush(.addTransaction)
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
        .onAppear {
            vm.refreshData()
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
        .environment(Coordinator())
}

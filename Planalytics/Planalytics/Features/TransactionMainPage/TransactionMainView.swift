//
//  TransactionsListView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI

struct TransactionMainView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: TransactionMainViewModel
    
    init(vm: TransactionMainViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.appBackground, Color.appAccent, Color.appSlate]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    Text("Egyenleg HUF")
                    HStack {
                        Text("\(vm.transBalance.formatted()) Ft")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
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
                    .padding()
                    .buttonStyle(.glass)
                    .fontWeight(.semibold)
                }
                if vm.transactions.isEmpty {
                    Text("Nincs megjeleníthető tranzakció")
                    Spacer()
                } else {
                    List {
                        ForEach(vm.transactions.reversed().prefix(3)) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                        .foregroundStyle(Color.appText)

                        HStack {
                            Spacer()
                            Button("Összes") {
                                coordinator.mainPush(.allTransactions)
                            }
                            .buttonStyle(.borderless)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            Spacer()
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    coordinator.mainPush(.transactionStatistics)
                } label: {
                    Image(systemName: "chart.bar.fill")
                }
            }
        }
        .onChange(of: coordinator.dataVersion) {
            withAnimation(.snappy) {
                vm.refreshData()
            }
        }
    }
}

#Preview {
    // memóriába mentő manager
    let mockManager = CoreDataManager.transactionListPreview()
    let vm = TransactionMainViewModel(
        container: mockManager
    )
    TransactionMainView(vm: vm)
        .environment(Coordinator())
}

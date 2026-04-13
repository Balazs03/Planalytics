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
            LinearGradient(gradient: Gradient(colors: [.mainBackground, .textBackground]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    Text("Egyenleg HUF")
                    HStack {
                        Text("\(vm.transBalance.formatted()) Ft")
                            .font(.system(.largeTitle, weight: .bold))
                            .contentTransition(.numericText())
                            .animation(.default, value: vm.transBalance)
                        
                        if vm.transBalance < 0 {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.largeTitle)
                        }
                    }
                }
            
                Button {
                    coordinator.mainPush(.addTransaction)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Hozzáadás")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.glass)
                .fontWeight(.semibold)
                
                List {
                    if vm.transactions.isEmpty {
                        Text("Nincs megjeleníthető tranzakció")
                        Spacer()
                    } else {
                        Section {
                            ForEach(vm.transactions.reversed().prefix(3)) { transaction in
                                TransactionRowView(transaction: transaction)
                            }
                            
                            HStack {
                                Spacer()
                                Button {
                                    coordinator.mainPush(.allTransactions(showRecurrentOnly: false))
                                } label: {
                                    Text("Összes")
                                }
                                .buttonStyle(.borderless)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                Spacer()
                            }
                        } header: {
                            Text("Tranzakciók")
                        }
                    }
                    
                    if !vm.recurrentTransactions.isEmpty {
                        Section {
                            ForEach(vm.recurrentTransactions.reversed().prefix(3)) { recurrentTransaction in
                                TransactionRowView(transaction: recurrentTransaction)
                            }
                            
                            HStack {
                                Spacer()
                                Button {
                                    coordinator.mainPush(.allTransactions(showRecurrentOnly: true))
                                } label: {
                                    Text("Összes")
                                }
                                .buttonStyle(.borderless)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                Spacer()
                            }
                        } header: {
                            Text("Ismétlődő tranzakciók")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
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
            ToolbarItem(placement: .automatic) {
                Button {
                    coordinator.mainPush(.settings)
                } label: {
                    Label("Beállítások", systemImage: "gearshape.fill")
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

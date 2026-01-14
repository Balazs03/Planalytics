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
            VStack(alignment: .leading,spacing: 25) {
                YearMonthPickerView(selectedDate: $vm.selectedDate)
                
                if !vm.transactions.isEmpty {
                    TransactionsChart(groupedTransactions: vm.groupedTransactions, totalExpenses: vm.totalExpenses)
                } else {
                    Text("Az adott időszakban még nincsenek tranzakciók")
                }
                
                Divider()
                InfoRowView(label: "Kiadások", value: "\(vm.totalExpenses.formatted(.number.precision(.fractionLength(2)))) Ft")
                
                InfoRowView(label: "Bevételek", value: "\(vm.totalIncomes.formatted(.number.precision(.fractionLength(2)))) Ft")
            }
            .padding()
            .background(Color.appSlate.brightness(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nettó pénzforgalom")
                        .foregroundStyle(.secondary)
                    Text("\((vm.totalIncomes - vm.totalExpenses).formatted()) Ft")
                        .fontWeight(.semibold)
                    if vm.balance {
                        Label {
                            Text("Pozitív")
                        } icon: {
                            Image(systemName: "plus.circle.fill")
                        }
                            .foregroundStyle(.green)
                    } else {
                        Label {
                            Text("Negatív")
                        } icon: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .foregroundStyle(.red)
                    }
                }
                .padding()
                .background(Color.appSlate.brightness(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            }
        }
        .navigationTitle("Statisztikák")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.appBackground)
        .onChange(of: vm.selectedDate) {
            vm.refreshData()
        }
    }
}

#Preview {
    let mockManager = CoreDataManager.transactionListPreview()
    let vm = TransactionStatisticsViewModel(container: mockManager)
    TransactionStatisticsView(vm: vm)
        .environment(Coordinator())
}

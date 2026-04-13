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
    @AppStorage("appLanguage") private var appLanguage: String = "hu"

    init(vm: TransactionStatisticsViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    YearMonthSelection(selectedYear: $vm.selectedYear, selectedMonth: $vm.selectedMonth, firstYear: vm.firstTransactionYear)
                    Text("Kiadások kategóriánként")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)

                    if !vm.expenses.isEmpty {
                        TransactionsChart(groupedTransactions: vm.groupedTransactions, totalExpenses: vm.totalExpenses)
                    } else {
                        Text("Az adott időszakban nem történtek kiadások")
                    }
                }
                .padding()
                .background()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Kiadások")
                            .fontWeight(.bold)
                            .font(.title3)
                        Text("\(vm.totalExpenses.formatted(.number.precision(.fractionLength(2)))) Ft")
                            .fontWeight(.semibold)
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 100)
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bevételek")
                            .fontWeight(.bold)
                            .font(.title3)
                        Text("\(vm.totalIncomes.formatted(.number.precision(.fractionLength(2)))) Ft")
                            .fontWeight(.semibold)
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 100)
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Nettó pénzforgalom")
                            .fontWeight(.bold)
                            .font(.title3)
                        Text("\((vm.totalIncomes - vm.totalExpenses).formatted()) Ft")
                            .fontWeight(.semibold)
                            .font(.title2)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 100)
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .padding()
        }
        .background(Color.thirdBackground)
        .navigationTitle("Statisztikák")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vm.selectedYear) {
            vm.refreshData()
        }
        .onChange(of: vm.selectedMonth) {
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

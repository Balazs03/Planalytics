//
//  TransactionsListView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI

struct TransactionMainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "isRecurrent == true"))
    var transactions : FetchedResults<Transaction>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date ,order: .forward)], predicate: NSPredicate(format: "isRecurrent == false"))
    var recurrentTransactions: FetchedResults<Transaction>
    
    private let financeService = FinancialService()
    
    private var transBalance : Decimal {
        financeService.calculateBalance(context: viewContext)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mainBackground, .textBackground]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    Text("Egyenleg HUF")
                    HStack {
                        Text("\(transBalance.formatted()) Ft")
                            .font(.system(.largeTitle, weight: .bold))
                            .contentTransition(.numericText())
                            .animation(.default, value: transBalance)
                        
                        if transBalance < 0 {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.largeTitle)
                        }
                    }
                }
                
                NavigationLink(value: Page.addTransaction) {
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
                    if transactions.isEmpty {
                        Text("Nincs megjeleníthető tranzakció")
                        Spacer()
                    } else {
                        Section {
                            ForEach(transactions.reversed().prefix(3)) { transaction in
                                TransactionRowView(transaction: transaction)
                            }
                            
                            HStack {
                                Spacer()
                                
                                NavigationLink(value: Page.allTransactions(showRecurrentOnly: false)) {
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
                    
                    if !recurrentTransactions.isEmpty {
                        Section {
                            ForEach(recurrentTransactions.reversed().prefix(3)) { recurrentTransaction in
                                TransactionRowView(transaction: recurrentTransaction)
                            }
                            
                            HStack {
                                Spacer()
                                NavigationLink(value: Page.allTransactions(showRecurrentOnly: true)) {
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
                NavigationLink(value: Page.transactionStatistics) {
                    Image(systemName: "chart.bar.fill")
                }
            }
            ToolbarItem(placement: .automatic) {
                NavigationLink(value: Page.settings) {
                    Label("Beállítások", systemImage: "gearshape.fill")
                }
            }
        }
    }
}

#Preview {
    // memóriába mentő manager
    let mockManager = CoreDataManager.transactionListPreview()
    TransactionMainView()
        .environment(\.managedObjectContext, mockManager.context)
}

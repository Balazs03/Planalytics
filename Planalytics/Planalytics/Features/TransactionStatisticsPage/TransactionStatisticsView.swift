//
//  TransactionStatisticsView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 12..
//

import SwiftUI
internal import CoreData

struct TransactionStatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .forward)], predicate: NSPredicate(format: "isRecurrent == false AND type == 1"))
    private var expenses : FetchedResults<Transaction>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .forward)], predicate: NSPredicate(format: "isRecurrent == false AND type == 0"))
    private var incomes : FetchedResults<Transaction>
    
    @State private var selectedYear: Int = Calendar.current.component(.year ,from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month ,from: Date())
    
    private var chartData: [(category: TransactionCategory, amount: Decimal)] {
        let categoryDict = Dictionary(grouping: expenses, by: \.transactionCategory)
        
        let result = categoryDict.compactMap { (category, transactions) -> (category: TransactionCategory, amount: Decimal)? in
            
            guard let validCategory = category else {
                return nil
            }
            
            var sum: Decimal = 0
            
            for transaction in transactions {
                sum += transaction.amount.decimalValue
            }
            
            return (category: validCategory, amount: sum)
        }
        
        return result.sorted { $0.amount < $1.amount }
    }
    
    private var firstTransactionYear: Int {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        
        request.predicate = NSPredicate(format: "isRecurrent == false")
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        request.fetchLimit = 1
        
        do {
            let result = try viewContext.fetch(request)
            return Calendar.current.component(.year, from: result.first!.date)
        } catch {
            return Calendar.current.component(.year, from: Date())
        }
        
    }
    
    var totalExpenses: Decimal {
        expenses.reduce(0) { $0 + $1.amount.decimalValue }
    }
    
    var totalIncomes: Decimal {
        incomes.reduce(0) { $0 + $1.amount.decimalValue }
    }
    
    var balance: Bool {
        return (totalIncomes - totalExpenses) > 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    YearMonthSelection(selectedYear: $selectedYear, selectedMonth: $selectedMonth, firstYear: firstTransactionYear)
                    Text("Kiadások kategóriánként")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)

                    if !expenses.isEmpty {
                        TransactionsChart(chartData: chartData, totalExpenses: totalExpenses)
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
                        Text("\(totalExpenses.formatted(.number.precision(.fractionLength(2)))) Ft")
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
                        Text("\(totalIncomes.formatted(.number.precision(.fractionLength(2)))) Ft")
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
                        Text("\((totalIncomes - totalExpenses).formatted()) Ft")
                            .fontWeight(.semibold)
                            .font(.title2)
                        if balance {
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
        .onAppear {
            updateDateFilter()
        }
        .onChange(of: selectedYear) { _, _ in
            updateDateFilter()
        }
        .onChange(of: selectedMonth) { _, _ in
            updateDateFilter()
        }
    }
    
    func updateDateFilter() {
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
        
        guard let startDate = Calendar.current.date(from: dateComponents),
                let nextMonth: Date = Calendar.current.date(byAdding: .month, value: 1, to: startDate) else { return }
        
        expenses.nsPredicate = NSPredicate(
            format: "isRecurrent == false AND type == 1 AND date >= %@ AND date < %@",
            startDate as NSDate,
            nextMonth as NSDate
        )
        
        incomes.nsPredicate = NSPredicate(
            format: "isRecurrent == false AND type == 0 AND date >= %@ AND date < %@",
            startDate as NSDate,
            nextMonth as NSDate
        )
    }
}

#Preview {
    let mockManager = CoreDataManager.transactionListPreview()
    TransactionStatisticsView()
        .environment(\.managedObjectContext, mockManager.context)
}

//
//  StatisticsSheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 09..
//

import SwiftUI
import Charts

struct GoalStatisticsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: GoalStatisticsSheetViewModel
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    
    init(vm: GoalStatisticsSheetViewModel) {
        self.vm = vm
    }
    
    @ViewBuilder
    func GoalChart(transactions: [transHolder]?, vm: GoalStatisticsSheetViewModel, selectedDate: Date?) -> some View{
        if let transactions = transactions {
            VStack(alignment: .leading) {
                if let selectedDate = vm.selectedDate, let matchingValue = transactions.last(where: { Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: selectedDate) }) {
                    
                    Text("\(matchingValue.total.formatted(.number.precision(.fractionLength(2)))) Ft")
                        .font(.largeTitle)
                    
                    Text(selectedDate.formatted(date: .numeric, time: .omitted))

                } else {
                    Text("\((vm.goal.saving?.decimalValue ?? 0).formatted(.number.precision(.fractionLength(2)))) Ft")                        .font(.largeTitle)
                }
                Chart {
                    ForEach(transactions) { transaction in
                        LineMark(
                            x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                            y: .value("Összeg", transaction.total)
                        )
                        
                        AreaMark(
                            x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                            y: .value("Összeg", transaction.total)
                        )
                        .opacity(0.3)
                        
                        PointMark(
                            x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                            y: .value("Összeg", transaction.total)
                        )
                        .symbolSize(100)
                        .foregroundStyle(.blue)
                        .opacity(selectedDate == nil || vm.selectedTransHolder?.date == transaction.date ? 1 : 0.3)
                        
                    }
                }
                .chartScrollableAxes(vm.selectedFilter == .daily ? []: .horizontal)
                .chartXVisibleDomain(length: vm.selectedFilter.axisLength)
                .chartXSelection(value: $vm.selectedDate)
                .chartXScale(range: .plotDimension(padding: 20))
                .chartYScale(domain: 0...max(((vm.goal.amount).decimalValue * 1.2), ((vm.goal.saving)?.decimalValue ?? 1) * 1.2, (vm.maxGoalSaving)))
                .chartXAxis {
                    AxisMarks(values: .stride(by: vm.selectedFilter.date, count: vm.selectedFilter.count)) { value in
                        if let date = value.as(Date.self) {
                            let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
                            AxisValueLabel {
                                VStack(alignment: .leading) {
                                    if value.index == 0 {
                                        Text(date, format: .dateTime.day())
                                        Text(date, format: .dateTime.month())
                                        Text(date, format: .dateTime.year())
                                    } else {
                                        switch vm.selectedFilter {
                                        case .daily:
                                            Text(date, format: .dateTime.day())
                                            
                                        case .monthly:
                                            Text(date, format: .dateTime.month())
                                            
                                            if components.month == 1 && (value.index > 1 || value.index > 4){
                                                Text(date, format: .dateTime.year())
                                            }
                                        case .yearly:
                                            Text(date, format: .dateTime.year())
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 10) {
                        Text("Megtakarítási trend")
                            .font(.headline)
                        
                        switch vm.selectedFilter {
                        case .daily:
                            if let firstYear = vm.firstYear {
                                YearMonthSelection(selectedYear: $vm.selectedYear, selectedMonth: $vm.selectedMonth, firstYear: firstYear)
                            }
                            GoalChart(transactions: vm.filteredTransactions, vm: vm, selectedDate: vm.selectedDate)
                                .frame(minHeight: 200)
                        case .monthly:
                            GoalChart(transactions: vm.monthlyTransactions, vm: vm, selectedDate: vm.selectedDate)
                                .frame(minHeight: 200)
                        case .yearly:
                            GoalChart(transactions: vm.yearlyTransactions, vm: vm, selectedDate: vm.selectedDate)
                                .frame(minHeight: 200)
                        }
                        
                        Picker("Szűrés", selection: $vm.selectedFilter) {
                            ForEach(ChartDateFilter.allCases, id: \.self) { filter in
                                Text(appLanguage == "hu" ? filter.nameHu : filter.nameEn).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        
                        // INFO SOROK
                        Divider()
                        if let firstDate = vm.dailyTransactions?.first?.date {
                            let label = appLanguage == "hu" ? "Első megtakarítás" : "First saving"
                            InfoRowView(label: label, value: firstDate.formatted(date: .numeric, time: .omitted)
                            )
                        }
                        if let lastDate = vm.dailyTransactions?.last?.date {
                            let label = appLanguage == "hu" ? "Utolsó megtakarítás" : "Last saving"
                            InfoRowView(label: label, value: lastDate.formatted(date: .numeric, time: .omitted)
                            )
                            Divider()
                        }
                        
                        if let saving = vm.goal.saving, saving.doubleValue < vm.goal.amount.doubleValue, let predictions = vm.predictionBoundaries {
                            if let lower = predictions.min(),
                               let upper = predictions.max()  {
                                HStack {
                                    Text("Becsült befejezés")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(lower.formatted(date: .numeric, time: .omitted)) - \(upper.formatted(date: .numeric, time: .omitted))")
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.trailing)
                                }
                                                                    
                                if vm.goal.plannedCompletionDate > upper {
                                    Label {
                                        Text("Az eddigi megtakarítási trend alapján a cél a tervezett dátum után fog teljesülni")
                                    } icon: {
                                        Image(systemName: "exclamationmark.circle")
                                            .foregroundStyle(.yellow)
                                    }

                                } else if vm.goal.plannedCompletionDate > lower {
                                    Label {
                                        Text("Az eddigi megtakarítási trend alapján a cél a tervezett időn belül teljesülhet")
                                    } icon: {
                                        Image(systemName: "checkmark.circle")
                                            .foregroundStyle(.green)
                                    }

                                }
                                
                                else {
                                    Label {
                                        Text("Az eddigi megtakarítási trendet követve a cél a tervezett dátum előtt teljesülhet")
                                            .foregroundStyle(.secondary)
                                    } icon: {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(.blue)
                                    }

                                }
                            }
                        }
                        
                        if vm.distinctDates >= 1 {
                            Text("\(vm.distinctDates) különböző alkalommal történt feltöltés")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Még nem történt feltöltés")
                        }
                    }
                    .padding()
                    .background(.secondaryBackground.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                    
                    // FIGYELMEZTETŐ SZÖVEG (A kártyán kívül)
                    if vm.distinctDates < 7 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("A becsléshez tölts fel még \(7 - vm.distinctDates) különböző nap tranzakciókat")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        
                        if let monthlySaving = vm.monthlySavingplan  {
                            let text = appLanguage == "hu" ? "Szükséges havi összeg a cél eléréséért": "Monthly amount needed to achieve the goal"
                            StaticCardView(text: text, value: "\(monthlySaving.formatted(.number.precision(.fractionLength(2)))) Ft")
                        }
                        let text = appLanguage == "hu" ? "Hátralévő napok" : "Remaining days"
                        StaticCardView(text: text, value: "\(vm.daysUntilCompletion > 0 ? vm.daysUntilCompletion: 0 )")

                        if let maxTransactionAmount = vm.maxTransactionAmount {
                            let text = appLanguage == "hu" ? "Eddig fetöltött legnagyobb összeg" : "Largest amount saved so far"
                            StaticCardView(text: text, value: "\(maxTransactionAmount.formatted()) Ft")

                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Statisztikák")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }){
                        Image(systemName: "arrow.backward")
                    }
                }
            }
        }
    }
}

#Preview {
    let inMemoryContainer = CoreDataManager.goalsListPreview()
    let vm = GoalStatisticsSheetViewModel(container: inMemoryContainer, goal: inMemoryContainer.fetchGoals().first!)
    GoalStatisticsSheet(vm : vm)
}

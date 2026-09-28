//
//  StatisticsSheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 09..
//

import SwiftUI
import Charts

struct GoalStatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    @State private var statisticsService = GoalStaticticsService()
    
    @ObservedObject var goal: Goal
    @State private var goalResults: GoalStaticticsService.Result?
    @State private var monthlySavingplan: Decimal?
    @State private var selectedFilter: ChartDateFilter = .monthly
    @State private var selectedYear: Int = Calendar.current.dateComponents([.year], from: Date()).year!
    @State private var selectedMonth: Int = Calendar.current.dateComponents([.month], from: Date()).month!
    @State private var filteredTransactions: [ChartDataPoint]?
    @State private var datesDictionary: [Int: Set<Int>]?
    @State private var selectedChartDate: Date?
    
    var firstYear: Int? {
        guard let datesDictionary else { return nil }
        
        return datesDictionary.keys.sorted().min()
    }
    
    var daysUntilCompletion: Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: goal.plannedCompletionDate).day ?? 1
    }
    var maxTransactionAmount: Decimal {
        guard let transactions = goal.transactions as? Set<Transaction> else {return 0}
        
        let expenseTransaction = transactions.filter { $0.transactionType == .expense }
        
        guard !expenseTransaction.isEmpty else {return 0}
        
        let maxTransaction = expenseTransaction.max { $0.amount.decimalValue < $1.amount.decimalValue }
        
        return maxTransaction?.amount.decimalValue ?? 0
    }
    
    var maxGoalSaving: Decimal {
        return goalResults?.daily.map { $0.total }.max() ?? 0
    }
    
    @ViewBuilder
    func GoalChart(transactions: [ChartDataPoint]?, selectedDate: Binding<Date?>) -> some View {
        if let transactions = transactions {
            VStack(alignment: .leading) {
                if let selectedDate = selectedDate.wrappedValue, let matchingValue = transactions.last(where: { Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: selectedDate) }) {
                    
                    Text("\(matchingValue.total.formatted(.number.precision(.fractionLength(2)))) Ft")
                        .font(.largeTitle)
                    
                    Text(selectedDate.formatted(date: .numeric, time: .omitted))

                } else {
                    Text("\((goal.saving?.decimalValue ?? 0).formatted(.number.precision(.fractionLength(2)))) Ft")
                        .font(.largeTitle)
                }
                Chart {
                    ForEach(transactions) { transaction in
                        LineMark(
                            x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                            y: .value("Összeg", transaction.total)
                        )
                        .interpolationMethod(.stepEnd)
                        
                        AreaMark(
                            x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                            y: .value("Összeg", transaction.total)
                        )
                        .interpolationMethod(.stepEnd)
                        .opacity(0.3)
                        
                        PointMark(
                            x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                            y: .value("Összeg", transaction.total)
                        )
                        .symbolSize(100)
                        .foregroundStyle(.blue)
                        .opacity(selectedDate.wrappedValue == nil || selectedDate.wrappedValue == transaction.date ? 1 : 0.3)
                        
                    }
                }
                .chartScrollableAxes(selectedFilter == .daily ? []: .horizontal)
                .chartXVisibleDomain(length: selectedFilter.axisLength)
                .chartXSelection(value: selectedDate)
                .chartXScale(range: .plotDimension(padding: 20))
                .chartYScale(domain: 0...max(((goal.amount).decimalValue * 1.2), ((goal.saving)?.decimalValue ?? 1) * 1.2, (maxGoalSaving)))
                .chartXAxis {
                    AxisMarks(values: .stride(by: selectedFilter.date, count: selectedFilter.count)) { value in
                        if let date = value.as(Date.self) {
                            let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
                            AxisValueLabel {
                                VStack(alignment: .leading) {
                                    if value.index == 0 {
                                        Text(date, format: .dateTime.day())
                                        Text(date, format: .dateTime.month())
                                        Text(date, format: .dateTime.year())
                                    } else {
                                        switch selectedFilter {
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
        Group {
            if let results = goalResults, let monthlySaving = monthlySavingplan {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        VStack(spacing: 10) {
                            Text("Megtakarítási trend")
                                .font(.headline)
                            
                            switch selectedFilter {
                            case .daily:
                                if let firstYear = firstYear {
                                    YearMonthSelection(selectedYear: $selectedYear, selectedMonth: $selectedMonth, firstYear: firstYear)
                                }
                                GoalChart(transactions: results.daily, selectedDate: $selectedChartDate)
                                    .frame(minHeight: 200)
                            case .monthly:
                                GoalChart(transactions: results.monthly, selectedDate: $selectedChartDate)
                                    .frame(minHeight: 200)
                            case .yearly:
                                GoalChart(transactions: results.yearly, selectedDate: $selectedChartDate)
                                    .frame(minHeight: 200)
                            }
                            
                            Picker("Szűrés", selection: $selectedFilter) {
                                ForEach(ChartDateFilter.allCases, id: \.self) { filter in
                                    Text(appLanguage == "hu" ? filter.nameHu : filter.nameEn).tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            // INFO SOROK
                            Divider()
                            if let firstDate = results.daily.first?.date {
                                let label = appLanguage == "hu" ? "Első megtakarítás" : "First saving"
                                InfoRowView(label: label, value: firstDate.formatted(date: .numeric, time: .omitted)
                                )
                            }
                            if let lastDate = results.monthly.last?.date {
                                let label = appLanguage == "hu" ? "Utolsó megtakarítás" : "Last saving"
                                InfoRowView(label: label, value: lastDate.formatted(date: .numeric, time: .omitted)
                                )
                                Divider()
                            }
                            
                            if let saving = goal.saving, saving.doubleValue < goal.amount.doubleValue, let predictions = results.predictionBoundaries {
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
                                    
                                    if goal.plannedCompletionDate > upper {
                                        Label {
                                            Text("Az eddigi megtakarítási trend alapján a cél a tervezett dátum után fog teljesülni")
                                        } icon: {
                                            Image(systemName: "exclamationmark.circle")
                                                .foregroundStyle(.yellow)
                                        }
                                        
                                    } else if goal.plannedCompletionDate > lower {
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
                            
                            if results.distinctDates >= 1 {
                                Text("\(results.distinctDates) különböző alkalommal történt feltöltés")
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
                        if results.distinctDates < 7 {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("A becsléshez tölts fel még \(7 - results.distinctDates) különböző nap tranzakciókat")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding()
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            
                            let monthlyText = appLanguage == "hu" ? "Szükséges havi összeg a cél eléréséért": "Monthly amount needed to achieve the goal"
                            StaticCardView(text: monthlyText, value: "\(monthlySaving.formatted(.number.precision(.fractionLength(2)))) Ft")
                            
                            let reaminigDaysText = appLanguage == "hu" ? "Hátralévő napok" : "Remaining days"
                            StaticCardView(text: reaminigDaysText, value: "\(daysUntilCompletion > 0 ? daysUntilCompletion: 0 )")
                            
                            let text = appLanguage == "hu" ? "Eddig fetöltött legnagyobb összeg" : "Largest amount saved so far"
                            StaticCardView(text: text, value: "\(maxTransactionAmount.formatted()) Ft")
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            } else {
                ProgressView("Adatok betöltése")
            }
        }
        .task {
            preCalculations()
            await calculateTransaction()
        }
        .onChange(of: selectedYear) { oldValue, newValue in
            if let results = goalResults {
                if let months = results.datesDict[newValue], let minMonth = months.min() {
                    selectedMonth = minMonth
                } else {
                    selectedMonth = 1
                }
                
                filteredTransactions = statisticsService.updateFilteredTransactions(
                    dailyTransaction: results.daily,
                    selectedYear: selectedYear,
                    selectedMonth: selectedMonth
                )
            }
        }
        .onChange(of: selectedMonth) {
            if let results = goalResults {
                filteredTransactions = statisticsService.updateFilteredTransactions(
                    dailyTransaction: results.daily,
                    selectedYear: selectedYear,
                    selectedMonth: selectedMonth
                )
            }
        }
        .navigationTitle("Statisztikák")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @MainActor
    func calculateTransaction() async {
        guard let transactions = goal.transactions as? Set<Transaction> else { return }
        
        self.goalResults = await statisticsService.process(
            transactions: transactions,
            targetAmount: goal.amount.decimalValue,
        )
    }
    
    func preCalculations() {
        self.monthlySavingplan = statisticsService.calculateRequiredMonthlySaving(goal: self.goal)
    }
    
    enum ChartDateFilter: String, CaseIterable {
        case yearly
        case monthly
        case daily
        
        var nameHu : String {
            switch self {
            case .daily:
                return "Napi"
            case .monthly:
                return "Havi"
            case .yearly:
                return "Éves"
            }
        }
        
        var nameEn: String {
            switch self {
            case .daily:
                return "Daily"
            case .monthly:
                return "Monthly"
            case .yearly:
                return "Yearly"
            }
        }
        
        var date : Calendar.Component {
            switch self {
            case .daily:
                return .day
            case .monthly:
                return .month
            case .yearly:
                return .year
            }
        }
        
        var axisLength: Int {
            switch self {
                case .daily:
                return 60 * 60 * 24 * 20
            case .monthly:
                return 60 * 60 * 24 * 150
            case .yearly:
                return 60 * 60 * 24 * 730
            }
        }
        
        var count: Int {
            switch self {
            case .daily:
                return 7
            case .monthly:
                return 1
            case .yearly:
                return 1
            }
        }
    }
}

#Preview {
    let inMemoryContainer = CoreDataManager.goalsListPreview()
    GoalStatisticsView(goal: inMemoryContainer.fetchGoals().first!)
        .environment(\.managedObjectContext, inMemoryContainer.context)
}

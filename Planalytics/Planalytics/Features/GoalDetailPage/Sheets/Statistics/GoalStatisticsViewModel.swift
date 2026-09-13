//
//  StatisticsSheetViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 09..
//

import Foundation

@Observable
class GoalStatisticsViewModel {
    var datesDictionary: [Int: Set<Int>]?
    var selectedYear: Int {
        didSet {
            updateSelectedMonth()
        }
    }
    var selectedDate: Date?
    
    var selectedMonth: Int {
        didSet {
            updateFilteredTransactions()
        }
    }
    var firstYear: Int? {
        guard let datesDictionary else { return nil }
        
        return datesDictionary.keys.sorted().min()
    }
    var daysUntilCompletion: Int
    var monthlySavingplan: Decimal?
    var maxTransactionAmount: Decimal? {
        guard let transactions = goal.transactions as? Set<Transaction> else {return 0}
        
        let expenseTransaction = transactions.filter { $0.transactionType == .expense }
        
        guard !expenseTransaction.isEmpty else {return 0}
        
        let maxTransaction = expenseTransaction.max { $0.amount.decimalValue < $1.amount.decimalValue }
        
        return maxTransaction?.amount.decimalValue
    }
    
    var maxGoalSaving: Decimal {
        guard let transactions = dailyTransactions else {return 0}
        
        return transactions.map { $0.total }.max() ?? 0
    }
            
    init(container: CoreDataManager, goal: Goal) {
        self.container = container
        self.goal = goal
        self.model = LSMmodel(transactions: [])
        daysUntilCompletion = Calendar.current.dateComponents([.day], from: Date(), to: goal.plannedCompletionDate).day ?? 1
        let currentDate = Calendar.current.dateComponents([.year, .month], from: Date())
        selectedYear = currentDate.year!
        selectedMonth = currentDate.month!
        updateAllData()
        if distinctDates < 5 {
            selectedFilter = .daily
        }
    }
    
    func updateFilteredTransactions() {
        if let dailyTransactions = dailyTransactions {
                        
            self.filteredTransactions = dailyTransactions.filter{
                let components = Calendar.current.dateComponents([.year, .month], from: $0.date)
                return components.year == selectedYear && components.month == selectedMonth
            }
        }
    }
    
    func updateSelectedMonth() {
        if let datesDict = datesDictionary, let months = datesDict[selectedYear], let minMonth = months.min() {
                selectedMonth = minMonth
        }
    }
    
    func updateAllData() {
        monthlySavingplan = calculateRequiredMonthlySaving()
        datesDictionary = calculateYearsAndMonthsPickerDates()
        updateFilteredTransactions()
    }

    func calculateRequiredMonthlySaving() -> Decimal {
        // 1. Hátralévő összeg kiszámítása
        let remainingAmount = self.goal.amount.doubleValue - (self.goal.saving?.doubleValue ?? 0)
        
        // 2. Napok kiszámítása ÉS mentése azonnal (még a guardok előtt!)
        let days = Calendar.current.dateComponents([.day], from: Date(), to: self.goal.plannedCompletionDate).day ?? 0
        // 3. Ellenőrzések
        // Ha már összegyűlt a pénz, vagy lejárt az idő, 0 a havi teher
        guard remainingAmount > 0 else { return 0 }
        guard days >= 0 else { return 0 }
        
        // 4. Hónapok számítása (Double-ként, hogy ne legyen 0 az eredmény)
        // A max(..., 1.0) biztosítja, hogy ha kevesebb mint 1 hónap van hátra,
        // akkor is el tudjuk osztani (úgy vesszük, mintha 1 hónap lenne, vagyis azonnal be kell fizetni).
        let monthsUntilCompletion = max(Double(days) / 30.0, 1.0)
        // 5. Végleges számítás
        return Decimal(remainingAmount) / Decimal(monthsUntilCompletion)
    }
    
    func calculateYearsAndMonthsPickerDates() -> [Int: Set<Int>]? {
        guard let yearlyTransactions, let monthlyTransactions else {
            return nil
        }
        
        var dateDict : [Int: Set<Int>] = [:]
        
        for transaction in yearlyTransactions {
            let yearComponent = Calendar.current.component(.year, from: transaction.date)
            dateDict[yearComponent] = []
        }
        
        for transaction in monthlyTransactions {
            let yearComponent = Calendar.current.component(.year, from: transaction.date)
            let monthComponent = Calendar.current.component(.month, from: transaction.date)
            dateDict[yearComponent, default: []].insert(monthComponent)
        }
        
        if let firstYear = dateDict.keys.first, let firstMonth = dateDict[firstYear]?.min(){
            selectedYear = firstYear
            selectedMonth = firstMonth
        }
        
        return dateDict
    }
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

struct ChartDataPoint: Identifiable {
    var id: UUID
    var total: Decimal
    var date: Date
}

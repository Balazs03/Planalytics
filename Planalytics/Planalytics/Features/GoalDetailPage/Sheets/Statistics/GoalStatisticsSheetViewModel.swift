//
//  StatisticsSheetViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 09..
//

import Foundation

@Observable
class GoalStatisticsSheetViewModel {
    let container: CoreDataManager
    let goal: Goal
    var model: LSMmodel
    var dailyTransactions: [transHolder]?
    var monthlyTransactions: [transHolder]?
    var yearlyTransactions: [transHolder]?
    var filteredTransactions: [transHolder]?
    var datesDictionary: [Int: Set<Int>]?
    var selectedYear: Int {
        didSet {
            updateSelectedMonth()
        }
    }
    var selectedMonth: Int {
        didSet {
            updateFilteredTransactions()
        }
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
    
    var selectedFilter: ChartDateFilter = .monthly
    
    var distinctDates: Int = 0
    
    var isLoading = false
    
    var predictionBoundaries: [Date]?
    
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
                        
            let year = selectedYear
            let month = selectedMonth
            self.filteredTransactions = dailyTransactions.filter{
                let components = Calendar.current.dateComponents([.year, .month], from: $0.date)
                return components.year == year && components.month == month
            }
        }
    }
    
    func updateSelectedMonth() {
        if let datesDict = datesDictionary, let months = datesDict[selectedYear], let minMonth = months.min() {
                selectedMonth = minMonth
        }
    }
    
    func updateAllData() {
        createTransactionHistory()
        calculateDistinctDates()
        monthlySavingplan = calculateRequiredMonthlySaving()
        datesDictionary = calculateYearsAndMonthsPickerDates()
        if distinctDates > 7 {
            calculatePredictionBoundaries()
        }
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
            dateDict[Calendar.current.component(.year, from: transaction.date)] = []
        }
        
        for transaction in monthlyTransactions {
            dateDict[Calendar.current.component(.year, from: transaction.date)]?.insert(Calendar.current.component(.month, from: transaction.date))
        }
        
        if let firstYear = dateDict.keys.first, let firstMonth = dateDict[firstYear]?.min(){
            selectedYear = firstYear
            selectedMonth = firstMonth
        }
        
        return dateDict
    }
    
    func calculatePredictionBoundaries() {
        guard let dailyTransactions else { return }
        model = LSMmodel(transactions: dailyTransactions)
        predictionBoundaries = model.predictConfidenceIntervals(forX: self.goal.amount as Decimal)
    }
    
    func calculateDistinctDates() {
        guard let transactions = dailyTransactions else {
            return
        }
        
        let dates = transactions.map { Calendar.current.startOfDay(for: $0.date) }
        
        self.distinctDates = Set(dates).count
    }
    
    func createTransactionHistory() {
        let intervalSet: [Set<Calendar.Component>] = [
            [.year, .month, .day],
            [.year, .month],
            [.year]
        ]
        
        dailyTransactions = createRollingSaves(interval: intervalSet[0])
        monthlyTransactions = createRollingSaves(interval: intervalSet[1])
        yearlyTransactions = createRollingSaves(interval: intervalSet[2])
    }
    
    func createRollingSaves(interval: Set<Calendar.Component>) -> [transHolder] {
        let transactions = goal.transactions as? Set<Transaction> ?? []
        
        // Első closureben megadjuk, hogy szeretnénk groupolni a dictionaryt, másodikban mapeljük a value-kat
        let tempDict = Dictionary(grouping: transactions) { transaction in
            let components = Calendar.current.dateComponents(interval, from: transaction.date)
            
            return Calendar.current.date(from: components)!
        } .mapValues { groupedTransactions in
            groupedTransactions.reduce(0) { (sum, transaction) -> Decimal in
                let amount = transaction.amount as Decimal
                return sum + (transaction.transactionType == .income ? -amount : amount)
            }
        }
        
        let sortedDates = tempDict.keys.sorted()
        var currentTotal: Decimal = 0.00
        var tempTransHolder: [transHolder] = []
        
        for date in sortedDates {
            if let value = tempDict[date] {
                currentTotal += value
            }
            
            tempTransHolder.append(transHolder(id: UUID(), total: currentTotal, date: date))
        }
        return tempTransHolder
    }
}

enum ChartDateFilter: String, CaseIterable {
    case yearly = "Éves"
    case monthly = "Havi"
    case daily = "Napi"
    
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

struct transHolder: Identifiable {
    var id: UUID
    var total: Decimal
    var date: Date
}

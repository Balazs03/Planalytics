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
    var YAxisMaxValue: Decimal = 0
    var daysUntilCompletion: Int?
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
    
    var selectedFilter: ChartDateFilter = .daily {
        didSet{
            calculateYAxisValues()
            calcualtePredictions()
        }
    }
    
    var distinctDates: Int = 0
    
    var predictedDates: [transHolder] = []
    var predictionBoundaries: [Date] = []
    
    init(container: CoreDataManager, goal: Goal) {
        self.container = container
        self.goal = goal
        self.model = LSMmodel(transactions: [])
        updateAllData()
        if distinctDates < 7 {
            selectedFilter = .daily
        }
    }
    
    func updateAllData() {
        createTransactionHistory()
        calculateDistinctDates()
        calculateYAxisValues()
        if distinctDates > 7 {
            calculatePredictionBoundaries()
            calcualtePredictions()
        }
    }
    
    func calculaterequiredMonthlySaving() -> Decimal? {
        let remainingAmount = self.goal.amount.doubleValue - (self.goal.saving?.doubleValue ?? 0)
        
        guard remainingAmount > 0 else { return 0 }
        
        let daysUntilCompletion = Calendar.current.dateComponents([.day], from: Date(), to: self.goal.plannedCompletionDate).day ?? 1
        
        guard daysUntilCompletion > 0 else { return 0 }
        
        self.daysUntilCompletion = daysUntilCompletion
        
        let monthsUntilCompletion = daysUntilCompletion / 30
        
        return Decimal(remainingAmount) / Decimal(monthsUntilCompletion)
    }
    
    func calculatePredictionBoundaries() {
        guard let dailyTransactions else { return }
        model = LSMmodel(transactions: dailyTransactions)
        predictionBoundaries = model.predictConfidenceIntervals(forX: self.goal.amount as Decimal)
    }
    
    func calcualtePredictions() {
        guard let dailyTransactions,
              let monthlyTransactions,
              let yearlyTransactions,
              let lastDayEntry = dailyTransactions.last,
              let lastMonthEntry = monthlyTransactions.last,
              let lastYearEntry = yearlyTransactions.last,
              distinctDates > 7 else { return }
        
        
        switch selectedFilter {
        case .yearly:
            model = LSMmodel(transactions: yearlyTransactions)
                        
            let endDate = model.predict(forX: self.goal.amount as Decimal)
            
            guard endDate > lastYearEntry.date else { return }
            
            self.predictedDates =  [
                transHolder(id: UUID(), total: lastYearEntry.total, date: lastYearEntry.date),
                transHolder(id: UUID(), total: goal.amount as Decimal, date: endDate)
            ]
        case .monthly:
            model = LSMmodel(transactions: monthlyTransactions)
                        
            let endDate = model.predict(forX: self.goal.amount as Decimal)
            
            guard endDate > lastMonthEntry.date else { return }
            
            self.predictedDates =  [
                transHolder(id: UUID(), total: lastMonthEntry.total, date: lastMonthEntry.date),
                transHolder(id: UUID(), total: goal.amount as Decimal, date: endDate)
            ]
        case .daily:
            model = LSMmodel(transactions: dailyTransactions)

            let endDate = model.predict(forX: self.goal.amount as Decimal)
            
            guard endDate > lastDayEntry.date else { return }
            
            self.predictedDates =  [
                transHolder(id: UUID(), total: lastDayEntry.total, date: lastDayEntry.date),
                transHolder(id: UUID(), total: goal.amount as Decimal, date: endDate)
            ]
        }
    }
    
    func calculateYAxisValues() {
        guard let dailyTransactions, let monthlyTransactions, let yearlyTransactions else { return }
        
        self.YAxisMaxValue = switch selectedFilter {
        case .daily:
            dailyTransactions.map(\.total).max() ?? 0
        case .monthly:
            monthlyTransactions.map(\.total).max() ?? 0
        case .yearly:
            yearlyTransactions.map(\.total).max() ?? 0
        }
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
    
    func progressPercentage(progress: Decimal) -> Double {
        return ((progress as NSDecimalNumber).doubleValue  / self.goal.amount.doubleValue) * 100
    }
    
    func createRollingSaves(interval: Set<Calendar.Component>) -> [transHolder] {
        let transactions = goal.transactions as? Set<Transaction> ?? []
        
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
    
    func generateDates() -> [Date]? {
        if let dailyTransactions = self.dailyTransactions {
            model = LSMmodel(transactions: dailyTransactions)
            var dates: [Date] = []
            
            var currentDate = dailyTransactions.last!.date
            let endDate = model.predict(forX: self.goal.amount as Decimal)
            
            while currentDate <= endDate {
                dates.append(currentDate)
                
                guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDate
            }
            
            return dates
        }
        return nil
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
}

struct transHolder: Identifiable {
    var id: UUID
    var total: Decimal
    var date: Date
}

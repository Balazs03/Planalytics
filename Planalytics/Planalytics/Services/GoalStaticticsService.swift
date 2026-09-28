//
//  GoalStaticticsService.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 09. 06..
//

import Foundation

struct GoalStaticticsService {
    struct Result {
        let daily: [ChartDataPoint]
        let monthly: [ChartDataPoint]
        let yearly: [ChartDataPoint]
        let distinctDates: Int
        let predictionBoundaries: [Date]?
        let datesDict: [Int: Set<Int>]
    }
    
    func process(transactions: Set<Transaction>, targetAmount: Decimal) async -> Result {
        return await Task.detached {
            let dailyTransactions = await createRollingSaves(interval: [.year, .month, .day], transactions: transactions)
            let monthlyTransactions = await createRollingSaves(interval: [.year, .month], transactions: transactions)
            let yearlyTransactions = await createRollingSaves(interval: [.year], transactions: transactions)
            let distinctDates = Set(dailyTransactions.map { Calendar.current.startOfDay(for: $0.date) }).count
            let datesDictionary = await calculateYearsAndMonthsPickerDates(yearlyTransactions: yearlyTransactions, monthlyTransactions: monthlyTransactions)
            
            if distinctDates > 10 {
                let model = await LSMmodel(transactions: dailyTransactions)
                let predictionBoundaries = await model.getPredictionIntervals(forX: targetAmount)
                return Result(daily: dailyTransactions, monthly: monthlyTransactions, yearly: yearlyTransactions, distinctDates: distinctDates, predictionBoundaries: predictionBoundaries, datesDict: datesDictionary)
            }
            
            return Result(daily: dailyTransactions, monthly: monthlyTransactions, yearly: yearlyTransactions, distinctDates: distinctDates, predictionBoundaries: nil, datesDict: datesDictionary)
        }.value
    }
    
    func createRollingSaves(interval: Set<Calendar.Component>, transactions: Set<Transaction>) -> [ChartDataPoint] {
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
        var tempTransHolder: [ChartDataPoint] = []
        
        for date in sortedDates {
            if let value = tempDict[date] {
                currentTotal += value
            }
            
            tempTransHolder.append(ChartDataPoint(id: UUID(), total: currentTotal, date: date))
        }
        return tempTransHolder
    }
    
    func updateFilteredTransactions(dailyTransaction: [ChartDataPoint], selectedYear: Int, selectedMonth: Int) -> [ChartDataPoint] {
        return dailyTransaction.filter{
            let components = Calendar.current.dateComponents([.year, .month], from: $0.date)
            return components.year == selectedYear && components.month == selectedMonth
        }
    }

    func calculateRequiredMonthlySaving(goal: Goal) -> Decimal {
        // 1. Hátralévő összeg kiszámítása
        let remainingAmount = goal.amount.doubleValue - (goal.saving?.doubleValue ?? 0)
        
        // 2. Napok kiszámítása ÉS mentése azonnal (még a guardok előtt!)
        let days = Calendar.current.dateComponents([.day], from: Date(), to: goal.plannedCompletionDate).day ?? 0
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
    
    func calculateYearsAndMonthsPickerDates(yearlyTransactions: [ChartDataPoint], monthlyTransactions: [ChartDataPoint]) -> [Int: Set<Int>] {
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
        
        return dateDict
    }
}

struct ChartDataPoint: Identifiable {
    var id: UUID
    var total: Decimal
    var date: Date
}

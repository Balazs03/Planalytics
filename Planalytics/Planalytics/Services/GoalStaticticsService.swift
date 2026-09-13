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
        let year: [ChartDataPoint]
        let distinctDates: Int
        let predictionBoundaries: [Date]?
    }
    
    func process(transactions: Set<Transaction>, targetAmount: Decimal) async -> Result {
        return await Task {
            let dailyTransactions = createRollingSaves(interval: [.year, .month, .day], transactions: transactions)
            let monthlyTransactions = createRollingSaves(interval: [.year, .month], transactions: transactions)
            let yearlyTransactions = createRollingSaves(interval: [.year], transactions: transactions)
            let distinctDates = Set(dailyTransactions.map { Calendar.current.startOfDay(for: $0.date) }).count
            
            if distinctDates > 10 {
                let model = LSMmodel(transactions: dailyTransactions)
                let predictionBoundaries = model.getPredictionIntervals(forX: targetAmount)
                return Result(daily: dailyTransactions, monthly: monthlyTransactions, year: yearlyTransactions, distinctDates: distinctDates, predictionBoundaries: predictionBoundaries)
            }
            
            return Result(daily: dailyTransactions, monthly: monthlyTransactions, year: yearlyTransactions, distinctDates: distinctDates, predictionBoundaries: nil)
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
}

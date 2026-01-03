//
//  GoalDetailPageViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import Foundation
internal import CoreData

@Observable
class GoalDetailViewModel {
    var goal: Goal
    let container :CoreDataManager
    var transBalance: Decimal = 0
    var transactionHistory: [transHolder]?
    var distinctDates: Int {
        guard let transactions = transactionHistory else { return 0 }
        
        let dates = transactions.map { Calendar.current.startOfDay(for: $0.date) }
        
        let distinctDates = Set(dates)
        
        return distinctDates.count
    }
    
    
    init(goal: Goal, container: CoreDataManager) {
        self.container = container
        self.goal = goal
        refreshData()
        createRollingSaves()
    }
    
    func refreshData() {
        container.context.refresh(goal, mergeChanges: true)
        let balances = container.calculateTotalBalance()
        transBalance = balances[1]
    }
    
    func createRollingSaves() {
        let transactions = goal.transactions as? Set<Transaction> ?? []
        
        let tempDict = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        } .mapValues { dayTransactions in
            dayTransactions.reduce(0) { (sum, transaction) -> Decimal in
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
        transactionHistory = tempTransHolder
    }
    
    func deleteGoal() {
        if let saving = goal.saving as? Decimal, saving > 0 {
            let newTrans = Transaction(context: container.context)
            newTrans.amount = goal.saving!
            newTrans.name = "\(goal.name) nevű célra félretett megtakarítás"
            newTrans.date = Date()
            newTrans.transactionType = .income
        }
        container.context.delete(goal)
        container.saveContext()
    }
}

struct transHolder: Identifiable {
    var id: UUID
    var total: Decimal
    var date: Date
}

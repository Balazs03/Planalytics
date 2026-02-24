//
//  PlanalyticsApp.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 28..
//

import SwiftUI
import BackgroundTasks
internal import CoreData

@main
struct PlanalyticsApp: App {
    // Belépési pontnál létrehozom a coordinatort, hogy az legyen a root view
    @State private var coordinator = Coordinator()
    let persistentController = CoreDataManager.shared
    
    func scheduleAppRefresh() {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day,value: 1, to: today)
        
        let request = BGAppRefreshTaskRequest(identifier: "UploadTransactions")
        request.earliestBeginDate = tomorrow
        try? BGTaskScheduler.shared.submit(request)
    }
    
    func uploadTransactions() {
        let transactions = persistentController.fetchTransactions(year: nil, month: nil)
        let today = Calendar.current.startOfDay(for: .now)
        
        let recurrentTransactions = transactions.filter({ $0.isRecurrent })
        
        for transaction in recurrentTransactions {
            guard let nextExecution = transaction.recurrenceStartDate else { continue }
            var executionDay = Calendar.current.startOfDay(for: nextExecution)
            
            while today >= executionDay {
                
                let tempTransaction = Transaction(context: persistentController.context)
                tempTransaction.amount = transaction.amount
                tempTransaction.date = executionDay
                
                var nextDate: Date?
                switch transaction.recurrenceWrapper {
                case .daily:
                    nextDate = Calendar.current.date(byAdding: .day, value: 1, to: executionDay)
                case .weekly:
                    nextDate = Calendar.current.date(byAdding: .day, value: 7, to: executionDay)
                case .monthly:
                    nextDate = Calendar.current.date(byAdding: .month, value: 1, to: executionDay)
                case .none:
                    break
                }
                
                transaction.recurrenceStartDate = nextDate
                
                if let name = transaction.name {
                    tempTransaction.name = "Időzítve: \(name)"
                } else {
                    tempTransaction.name = "Időzített tranzakció"
                }
                tempTransaction.transactionType = transaction.transactionType
                tempTransaction.transactionCategory = transaction.transactionCategory
                if let goal = transaction.goal {
                    tempTransaction.goal = goal
                }
                tempTransaction.isRecurrent = false
                
                guard let nextDate else { break }
                
                executionDay = nextDate
            }
        }
        
        persistentController.saveContext()
    }
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(container: persistentController)
                .environment(coordinator)
                .onAppear {
                    scheduleAppRefresh()
                    uploadTransactions()
                }
        }
        .backgroundTask(.appRefresh("UploadTransactions")) {
            await scheduleAppRefresh()
            await uploadTransactions()
        }
    }
}

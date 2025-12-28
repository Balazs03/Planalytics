//
//  CoreDataManager.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 28..
//

import Foundation
internal import CoreData

class CoreDataManager {
    static var shared = CoreDataManager()
    let container: NSPersistentContainer
    
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Finance")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Hiba a Core Data betöltésében: \(error)")
            }
        })
    }
    // kulcsfontosságú a self, mert ezáltal amikor a preview-hoz készítünk egy inMemory managert
    // a preview alatt az lesz a self, amin a fetchTransactions lefut
    // ami a memóriából olvassa be az elemeket
    var context: NSManagedObjectContext { return self.container.viewContext }
    
    func saveContext () {
        do {
            try context.save()
        } catch {
            print("Sikertelen mentés: \(error)")
        }
    }
    
    // 2 verziót kapunk ezzel, az egyikben szűrni tudunk az évre és hónapra
    // a másikban megkapjuk az összes tranzakciót
    func fetchTransactions(year:Int?, month: Int?) -> [Transaction] {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        var predicates: [NSPredicate] = []
        
        if let year = year {
            let calendar = Calendar.current
            var dateTime = DateComponents()
            dateTime.year = year
            if let month = month {
                dateTime.month = month
            }
            
            let startDate: Date? = calendar.date(from: dateTime) ?? nil
            
            let endDate: Date? = {
                guard let startDate else { return nil }
                return calendar.date(byAdding: .month, value: 1, to: startDate)
            }()
            
            if let s = startDate, let e = endDate {
                let datePredicate = NSPredicate(
                    format: "date >= %@ AND date < %@",
                    s as NSDate,
                    e as NSDate
                )
                
                predicates.append(datePredicate)
            }
        }
        // ha a predicate nem üres, akkor AND kapcsolatot létesít köztük
        // vagyis az összes predicate ÉS kapcsolattal érvényesül
        if !predicates.isEmpty {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Probléma a lekérdezéskor: \(error)")
            return []
        }
    }
    
    func fetchGoals() -> [Goal] {
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        request.sortDescriptors = [NSSortDescriptor(key: "plannedCompletionDate", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Probléma a lekérdezéskor: \(error)")
            return []
        }
    }

    func calculateTotalBalance() -> [Decimal] {
        let transactions: [Transaction] = fetchTransactions(year: nil, month: nil)
        let goal: [Goal] = fetchGoals()
        
        var totalLiquidBalance: Decimal = 0
        
        for transaction in transactions {
            if transaction.transactionType == .income {
                totalLiquidBalance += transaction.amount as Decimal
            } else {
                totalLiquidBalance -= transaction.amount as Decimal
            }
        }
        
        let totalGoalBalance: Decimal = goal.reduce(0) { $0 + ($1.amount as Decimal) }
        
        return [totalGoalBalance + totalLiquidBalance, totalLiquidBalance, totalGoalBalance] as [Decimal]
    }
}

extension CoreDataManager {
    // memóriába mentett manager
    private static func createMemoryManager() -> CoreDataManager {
        return CoreDataManager(inMemory: true)
    }
    
    // példányosítja a memóriába mentett managert, majd létrehoz elemeket
    // Kulcselem: mivel a context-nél self-et használtunk, az az aktuális managert menti el
    // ami preview esetén a memóriába mentett, az alkalmazás futása közben pedig a háttértárra
    static func transactionListPreview() -> CoreDataManager {
        let manager = createMemoryManager()
                
        let previewContext = manager.context
        
        let myTransaction1 = Transaction(context: previewContext)
        myTransaction1.amount = 25000.2
        myTransaction1.name = "Bevásárlás"
        myTransaction1.date = Date()
        myTransaction1.transactionType = .expense
        myTransaction1.category = TransactionCategory.food.rawValue
        
        let myTransaction2 = Transaction(context: previewContext)
        myTransaction2.amount = 100000.0
        myTransaction2.name = "Fizetés"
        myTransaction2.date = Date()
        myTransaction2.transactionType = .income
        
        let myTransaction3 = Transaction(context: previewContext)
        myTransaction3.amount = 2500.6
        myTransaction3.name = "Ruha vásárlás"
        myTransaction3.date = Date()
        myTransaction3.transactionType = .expense
        myTransaction3.category = TransactionCategory.entertainment.rawValue
        
        let myTransaction4 = Transaction(context: previewContext)
        myTransaction4.amount = 1000.5
        myTransaction4.name = "Mozi"
        myTransaction4.date = Date()
        myTransaction4.transactionType = .expense
        myTransaction3.category = TransactionCategory.entertainment.rawValue
        
        manager.saveContext()
        return manager
    }
    
    static func goalsListPreview() -> CoreDataManager {
        let manager = createMemoryManager()
        
        let previewContext = manager.context
        
        let myGoal1 = Goal(context: previewContext)
        myGoal1.name = "Autó vásárlás"
        myGoal1.amount = 100000.0
        myGoal1.iconName = "car.side"
        myGoal1.creationDate = Date()
        myGoal1.desc = "Jövő év végére szeretnék venni egy autót."
        myGoal1.isFinished = false
        var calendar1 = DateComponents()
        calendar1.year = 2026
        calendar1.month = 12
        calendar1.day = 31
        myGoal1.plannedCompletionDate = Calendar.current.date(from: calendar1)!
        
        
        let myGoal2 = Goal(context: previewContext)
        myGoal2.name = "Kedvenc könyv"
        myGoal2.amount = 300.0
        myGoal2.iconName = "book"
        myGoal2.creationDate = Date()
        myGoal2.desc = "Mikulás napra szeretnék venni egy új könyvet."
        myGoal2.isFinished = false
        var calendar2 = DateComponents()
        calendar2.year = 2025
        calendar2.month = 12
        calendar2.day = 06
        myGoal2.plannedCompletionDate = Calendar.current.date(from: calendar2)!
        
        let myGoal3 = Goal(context: previewContext)
        myGoal3.name = "Fejhallgató vásárlás"
        myGoal3.amount = 40000.0
        myGoal3.iconName = "headphones"
        myGoal3.creationDate = Date()
        myGoal3.isFinished = false
        var calendar3 = DateComponents()
        calendar3.year = 2025
        calendar3.month = 12
        calendar3.day = 24
        myGoal3.plannedCompletionDate = Calendar.current.date(from: calendar3)!
        
        manager.saveContext()
        return manager
    }
}

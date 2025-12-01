//
//  CoreDataManager.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 28..
//

import Foundation
import CoreData

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
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Sikertelen mentés: \(error)")
            }
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
        request.sortDescriptors = [NSSortDescriptor(key: "plannedCompletionDate", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Probléma a lekérdezéskor: \(error)")
            return []
        }
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
    static func listPreview() -> CoreDataManager {
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
}

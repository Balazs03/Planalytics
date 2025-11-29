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
    
    private init() {
        container = NSPersistentContainer(name: "Finance")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Hiba a Core Data betöltésében: \(error)")
            }
        })
    }
    
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
                    format: "date >= %@ AND date <= %@",
                    s as NSDate,
                    e as NSDate
                )
                
                predicates.append(datePredicate)
            }
        }
        
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
    
    func fetchCategories() -> [Category] {
        let request = NSFetchRequest<Category>(entityName: "Category")
        
        do {
            return try context.fetch(request)
        } catch {
            print("Probléma a lekérdezéskor: \(error)")
            return []
        }
    }
}

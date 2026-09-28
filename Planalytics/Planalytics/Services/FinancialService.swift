//
//  FinancialService.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 08. 21..
//

import Foundation
internal import CoreData

struct FinancialService {
    func calculateBalance(context: NSManagedObjectContext) -> Decimal {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "isRecurrent == false")

        
        do {
            let result = try context.fetch(request)
            
            return result.reduce(0) { $0 + ($1.amount as Decimal) }
        } catch {
            return 0
        }
    }
}

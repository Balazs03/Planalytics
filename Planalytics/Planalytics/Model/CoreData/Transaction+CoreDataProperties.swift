//
//  Transaction+CoreDataProperties.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//
//

public import Foundation
public import CoreData


public typealias TransactionCoreDataPropertiesSet = NSSet

enum TransactionType: Int{
    case income = 0
    case expense = 1
}

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var date: Date
    @NSManaged public var name: String?
    @NSManaged public var type: Int16
    @NSManaged public var category: Category?
    
    var transactionType: TransactionType {
        get {
            return TransactionType(rawValue: Int(self.type)) ?? .expense
        }
        set {
            self.type = Int16(newValue.rawValue)
        }
    }
}

extension Transaction : Identifiable {

}

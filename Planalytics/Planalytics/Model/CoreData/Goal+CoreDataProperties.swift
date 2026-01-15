//
//  Goal+CoreDataProperties.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 01..
//
//

public import Foundation
public import CoreData


public typealias GoalCoreDataPropertiesSet = NSSet

extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var creationDate: Date
    @NSManaged public var desc: String?
    @NSManaged public var iconName: String?
    @NSManaged public var isFinished: Bool
    @NSManaged public var name: String
    @NSManaged public var plannedCompletionDate: Date
    @NSManaged public var saving: NSDecimalNumber?
    @NSManaged public var transactions: NSSet?
    
    var progress: Decimal {
        get {
            if let saved = self.saving {
                return saved.dividing(by: self.amount) as Decimal
            }
            return 0
        }
    }
    
    var iconNameWrapper: String {
        get {
            if let iconName {
                return iconName
            }
            return "pointer.arrow.click.2"
        }
        set {
            iconName = newValue
        }
    }
}

// MARK: Generated accessors for transactions
extension Goal: Identifiable {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}


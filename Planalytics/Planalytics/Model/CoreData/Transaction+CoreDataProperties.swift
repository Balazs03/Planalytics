//
//  Transaction+CoreDataProperties.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//
//

public import Foundation
public import CoreData
import SwiftUI


public typealias TransactionCoreDataPropertiesSet = NSSet

enum TransactionType: Int16, CaseIterable{
    case income = 0
    case expense = 1
    
    var title: String {
        switch self {
        case .income:
            return "Bevétel"
        case .expense:
            return "Kiadás"
        }
    }
}

enum TransactionCategory: Int16, CaseIterable{
    case food = 0
    case entertainment = 1
    case housing = 2
    case transportation = 3
    case healthAndEducation = 4
    
    var title : String {
        switch self {
        case .food:
            return "Élelmiszer"
        case .entertainment:
            return "Szórakozás és kultúra"
        case .housing:
            return "Lakhatás és rezsi"
        case .transportation:
            return "Közlekedés"
        case .healthAndEducation:
            return "Egészség és oktatás"
        }
    }
    
    var iconName: String {
        switch self {
        case .food:
            return "fork.knife"
        case .entertainment:
            return "theatermasks.fill"
        case .housing:
            return "bolt.house"
        case .transportation:
            return "car.side.fill"
        case .healthAndEducation:
            return "cross.circle.fill"
        }
    }
    
    var diagramColor: Color {
        switch self {
        case .food:
            return .green
        case .entertainment:
            return .blue
        case .housing:
            return .gray
        case .transportation:
            return .orange
        case .healthAndEducation:
            return .red
        }
    }
}

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var date: Date
    @NSManaged public var name: String?
    @NSManaged public var type: Int16
    @NSManaged public var category: Int16
    
    var transactionType: TransactionType {
        get {
            return TransactionType(rawValue: self.type) ?? .expense
        }
        set {
            self.type = Int16(newValue.rawValue)
        }
    }
    
    var transactionCategory: TransactionCategory? {
        get {
            return TransactionCategory(rawValue: self.category)
        }
        
        set {
            if let newValue {
                self.category = newValue.rawValue
            } else {
                self.category = -1
            }
        }
    }
}

extension Transaction : Identifiable {

}

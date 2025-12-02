//
//  AddGoalPageViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import Foundation
internal import CoreData

@Observable
class AddGoalPageViewModel {
    var name: String = ""
    var amount: Decimal = 0.0
    var plannedCompletionDate = Date()
    var desc: String?
    var iconNameWrapper: String = "pointer.arrow.click.2"
    let container: CoreDataManager
    
    init(container: CoreDataManager) {
        self.container = container
    }
    
    func addGoal(name: String, amount: Decimal, plannedCompletionDate: Date, desc: String?, iconName: String?) {
        let newGoal = Goal(context: container.context)
        newGoal.name = name
        newGoal.amount = amount as NSDecimalNumber
        newGoal.plannedCompletionDate = plannedCompletionDate
        newGoal.creationDate = Date()
        if let desc = desc {
            newGoal.desc = desc
        }
        if self.iconNameWrapper != "pointer.arrow.click.2" {
            newGoal.iconName = iconName
        }
        
        container.saveContext()
    }
    
}

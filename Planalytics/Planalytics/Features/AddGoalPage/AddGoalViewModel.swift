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
    var amount: Decimal?
    var plannedCompletionDate = Date()
    var desc: String?
    var iconNameWrapper: String = "pointer.arrow.click.2"
    let container: CoreDataManager
    
    init(container: CoreDataManager) {
        self.container = container
    }
    
    func addGoal() {
        guard let amount else { return }
        let newGoal = Goal(context: container.context)
        newGoal.name = self.name
        newGoal.amount = amount as NSDecimalNumber
        newGoal.plannedCompletionDate = self.plannedCompletionDate
        newGoal.creationDate = Date()
        if let desc = desc {
            newGoal.desc = desc
        }
        if self.iconNameWrapper != "pointer.arrow.click.2" {
            newGoal.iconNameWrapper = iconNameWrapper
        }
        
        container.saveContext()
    }
    
}

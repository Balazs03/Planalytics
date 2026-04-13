//
//  SelectGoalIntent.swift
//  PlanalyticsWidgetExtension
//
//  Created by Szabó Balázs on 2026. 02. 27..
//

import Foundation
import AppIntents
internal import CoreData

struct WidgetGoal: AppEntity {
    var id: String
    var name: String
    
    static var defaultQuery = WidgetGoalQuery()
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Célok"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct WidgetGoalQuery: EntityQuery {
    func entities(for identifiers: [WidgetGoal.ID]) async throws -> [WidgetGoal] {
        let goal = CoreDataManager.shared.fetchGoals()
        return goal.map { goal in
            let idString = goal.objectID.uriRepresentation().absoluteString
            return WidgetGoal(id: idString, name: goal.name)
        }
    }
    
    func suggestedEntities() async throws -> [WidgetGoal] {
        return CoreDataManager.shared.fetchGoals().map { goal in
            let idString = goal.objectID.uriRepresentation().absoluteString
            return WidgetGoal(id: idString, name: goal.name)
        }
    }
    
    func defaultResult() async -> WidgetGoal? {
        let goal = CoreDataManager.shared.fetchGoals()
        return goal.map { goal in
            return WidgetGoal(id: goal.objectID.uriRepresentation().absoluteString, name: goal.name)
        }.first
    }
    
}

struct SelectGoalIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Cél kiválasztása"
    static var description: IntentDescription = IntentDescription("Válaszd ki, melyik cél mutassa a widget")
    
    @Parameter(title: "Cél")
    var widgetGoal: WidgetGoal?
}

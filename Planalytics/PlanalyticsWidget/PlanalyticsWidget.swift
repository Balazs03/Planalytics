//
//  PlanalyticsWidget.swift
//  PlanalyticsWidget
//
//  Created by Szabó Balázs on 2026. 02. 24..
//

import WidgetKit
import SwiftUI
internal import CoreData

struct GoalTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> GoalEntry {
        GoalEntry(date: Date(), goal: getData().first)
    }

    func snapshot(for configuration: SelectGoalIntent, in context: Context) async -> GoalEntry {
        GoalEntry(date: Date(), goal: getData().first)
    }

    func timeline(for configuration: SelectGoalIntent, in context: Context) async -> Timeline<GoalEntry> {
        let container = CoreDataManager.shared
        let allGoals = container.fetchGoals()
        var selectedRealGoal: Goal? = nil
        
        if let selectedWidgetGoal = configuration.widgetGoal {
            selectedRealGoal = allGoals.first(where: { widgetGoal in
                widgetGoal.objectID.uriRepresentation().absoluteString == selectedWidgetGoal.id
            })
        }
        
        if selectedRealGoal == nil {
            selectedRealGoal = allGoals.first
        }
        
        return Timeline(entries: [
            GoalEntry(date: Date(), goal: selectedRealGoal)
        ], policy: .never
        )
    }
    
    func getData() -> [Goal] {
        let container = CoreDataManager.shared
        return container.fetchGoals()
    }
}

struct GoalEntry: TimelineEntry {
    var date: Date
    let goal: Goal?
}

struct PlanalyticsWidgetEntryView : View {
    var entry: GoalEntry

    var body: some View {
        if let goal = entry.goal {
            VStack(alignment: .leading) {
                ZStack {
                    Circle()
                        .fill(.secondaryBackground)
                        .frame(width: 48, height: 48)
                    Image(systemName: goal.iconNameWrapper)
                        .foregroundStyle(.textBackground)
                }
                Text(goal.name)
                Text("\((goal.progress * 100).formatted())%")
                Text("\(goal.plannedCompletionDate.formatted(.dateTime.year().month().day()))")
            }
        } else {
            Text("Jelenleg nincs aktív célod")
        }
    }
}

struct PlanalyticsWidget: Widget {
    let kind: String = "GoalWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "GoalWidget", intent: SelectGoalIntent.self, provider: GoalTimelineProvider()) { entry in
            PlanalyticsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Cél Widget")
        .description("Kövesd nyomon a kiválasztott célodat")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct PreviewData {
    static let manager = CoreDataManager.goalsListPreview()
}

#Preview(as: .systemSmall) {
    PlanalyticsWidget()
} timeline: {
    let goals = PreviewData.manager.fetchGoals()
    GoalEntry(date: .now, goal: goals.first)
}

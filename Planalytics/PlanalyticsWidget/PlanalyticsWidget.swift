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
        let allGoals = getData()
        var selectedRealGoal: Goal? = nil
        
        if let selectedWidgetGoal = configuration.widgetGoal {
            selectedRealGoal = allGoals.first(where: { goal in
                goal.objectID.uriRepresentation().absoluteString == selectedWidgetGoal.id
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
                // 1. HEADER: Icon and Percentage
                HStack {
                    ZStack {
                        Circle()
                            .fill(.secondaryBackground)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: goal.iconName ?? "chart.line.text.clipboard")
                            .font(.title3)
                            .foregroundStyle(.textBackground)
                    }
                    
                    Spacer()
                    
                    Text("\((goal.progress * 100).formatted(.number.precision(.fractionLength(0))))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(goal.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    ProgressView(value: NSDecimalNumber(decimal: goal.progress).doubleValue)
                        .tint(.mainBackground)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Text("Céldátum: \(goal.plannedCompletionDate.formatted(.dateTime.year().month().day()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding() // Gives it nice breathing room from the widget edges
            .containerBackground(.background, for: .widget) // Standard widget background
            
        } else {
            // 3. EMPTY STATE: Make it look intentional
            VStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
                Text("Jelenleg nincs aktív célod")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(.background, for: .widget)
        }
    }
}

struct PlanalyticsWidget: Widget {
    let kind: String = "GoalWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "GoalWidget", intent: SelectGoalIntent.self, provider: GoalTimelineProvider()) { entry in
            PlanalyticsWidgetEntryView(entry: entry)
                .containerBackground(.textBackground, for: .widget)
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

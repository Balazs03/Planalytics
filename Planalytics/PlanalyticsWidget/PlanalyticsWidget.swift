//
//  PlanalyticsWidget.swift
//  PlanalyticsWidget
//
//  Created by Szabó Balázs on 2026. 02. 24..
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> GoalEntry {
        GoalEntry(date: Date(), goal: getData().first)
    }

    func getSnapshot(in context: Context, completion: @escaping (GoalEntry) -> ()) {
        let entry = GoalEntry(date: Date(), goal: getData().first)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [GoalEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let entry = GoalEntry(date: Date(), goal: getData().first)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
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
            VStack {
                Text("Cél teszt vaaaa")
            }
        } else {
            Text("Jelenleg nincs aktív célod")
        }
    }
}

struct PlanalyticsWidget: Widget {
    let kind: String = "PlanalyticsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PlanalyticsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PlanalyticsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    PlanalyticsWidget()
} timeline: {
    let container = CoreDataManager.shared
    GoalEntry(date: .now, goal: container.fetchGoals().first)
}

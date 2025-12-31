//
//  GoalRowView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 31..
//

import SwiftUI


struct GoalRowView: View {
    // EZ A KULCS: @ObservedObject
    // Ez biztosítja, hogy ha a Core Data objektum bármely tulajdonsága változik,
    // ez a View azonnal újrarajzolódik, függetlenül a Listától.
    @ObservedObject var goal: Goal

    var body: some View {
        HStack {
            Image(systemName: goal.iconName ?? "pointer.arrow.click.2")
            VStack {
                // A név mögé tegyél biztonságos kicsomagolást (?? "")
                Text(goal.name)
                Text(
                    goal.plannedCompletionDate,
                    format: Calendar.current.isDate(goal.plannedCompletionDate, equalTo: Date(), toGranularity: .year)
                    ? .dateTime.month().day()
                    : .dateTime.year().month().day()
                )
            }
            Spacer()
            
            // Itt a progress, ami eddig nem frissült
            Image(systemName: goal.isFinished ? "checkmark.circle": "x.circle")
                .foregroundColor(goal.isFinished ? .green : .red)
            
            // Mivel a goal @ObservedObject, ez a számítás most már mindig friss lesz
            Text("\((goal.progress * 100).formatted())%")
        }
    }
}

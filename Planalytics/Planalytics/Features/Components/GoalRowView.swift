//
//  GoalRowView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 31..
//

import SwiftUI
internal import CoreData


struct GoalRowView: View {
    @ObservedObject var goal: Goal

    var body: some View {
        // HA A CÉL TÖRÖLT, VAGY NINCS MÁR CONTEXT-BEN, NE RAJZOLJUNK SEMMIT
        if goal.isDeleted || goal.managedObjectContext == nil {
            EmptyView()
        } else {
            HStack {
                Image(systemName: goal.iconName ?? "pointer.arrow.click.2")
                VStack(alignment: .leading) {
                    // Biztonságos szövegkezelés
                    Text(goal.name)
                    
                    Text(
                        goal.plannedCompletionDate,
                        format: Calendar.current.isDate(goal.plannedCompletionDate, equalTo: Date(), toGranularity: .year)
                        ? .dateTime.month().day()
                        : .dateTime.year().month().day()
                    )
                }
                Spacer()
                
                Image(systemName: goal.isFinished ? "checkmark.circle": "x.circle")
                    .foregroundColor(goal.isFinished ? .green : .red)
                
                // A progress kiszámítása előtt is érdemes ellenőrizni
                Text("\((goal.progress * 100).formatted())%")
            }
        }
    }
}

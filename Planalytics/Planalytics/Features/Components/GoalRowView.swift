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

    // Segédszín a progresszhez
    var statusColor: Color {
        if goal.isFinished { return .green }
        if goal.isDeleted { return .red }
        return .appAccent
    }

    var body: some View {
        // HA A CÉL TÖRÖLT, VAGY NINCS MÁR CONTEXT-BEN
        if goal.isDeleted || goal.managedObjectContext == nil {
            EmptyView()
        } else {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: goal.iconName ?? "target")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(
                            goal.plannedCompletionDate,
                            format: Calendar.current.isDate(goal.plannedCompletionDate, equalTo: Date(), toGranularity: .year)
                            ? .dateTime.month().day()
                            : .dateTime.year().month().day()
                        )
                    }
                    .font(.caption)
                    .foregroundStyle(Color.appSlate)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(statusColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 42, height: 42)
                        .rotationEffect(.degrees(-90)) // Hogy felülről induljon
                    
                    // Középső tartalom (Százalék vagy Pipa)
                    if goal.isFinished {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.green)
                    } else {
                        Text("\((goal.progress * 100).formatted(.number.precision(.fractionLength(0))))%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.appText)
                    }
                }
            }
            .padding()

        }
    }
}


#Preview {
    let mockManager = CoreDataManager.goalsListPreview()
    GoalRowView(goal: mockManager.fetchGoals().first!)
    
}

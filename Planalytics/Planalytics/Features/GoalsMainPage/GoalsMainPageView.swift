//
//  GoalsMainPageView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 01..
//

import SwiftUI

struct GoalsMainPageView: View {
    @State private var vm: GoalsMainPageViewModel
    
    init(vm: GoalsMainPageViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            Text("Aktív célok: \(vm.goals.count - vm.finishedGoalNumber)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            Text("Eddig befejezettek: \(vm.finishedGoalNumber)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
        }
        .padding()
        if vm.goals.isEmpty {
            Text("Nincsenek megadott célok")
        } else {
            List {
                ForEach(vm.goals, id: \.self) { goal in
                    if goal.isFinished == false {
                        HStack {
                            Image(systemName: goal.iconName ?? "pointer.arrow.click.2")
                            VStack {
                                Text(goal.name)
                                Text(
                                    goal.plannedCompletionDate, // Biztonságos kicsomagolás
                                    format: Calendar.current.isDate(goal.plannedCompletionDate, equalTo: Date(), toGranularity: .year)
                                        ? .dateTime.month().day()         // Ha idei év: Hónap, Nap
                                        : .dateTime.year().month().day()  // Ha más év: Év, Hónap, Nap
                                    )
                            }
                            Spacer()
                            Image(systemName: goal.isFinished ? "checkmark.circle": "x.circle")
                                .foregroundColor(goal.isFinished ? .green : .red)
                            Text("\((goal.progress * 100).formatted())%")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = GoalsMainPageViewModel(container: container)
    GoalsMainPageView(vm: vm)
}

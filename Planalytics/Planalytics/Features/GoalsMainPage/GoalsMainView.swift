//
//  GoalsMainPageView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 01..
//

import SwiftUI

struct GoalsMainView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: GoalsMainViewModel
    
    init(vm: GoalsMainViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Aktív célok: \(vm.goals.count - vm.finishedGoalNumber)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("Eddig befejezettek: \(vm.finishedGoalNumber)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            Button("Hozzáadás") {
                coordinator.goalPush(.addGoal)
            }
            
            if vm.goals.isEmpty {
                Text("Nincsenek megadott célok")
            } else {
                List {
                    ForEach(vm.goals, id: \.self) { goal in
                        if goal.isFinished == false {
                            NavigationLink(value: Page.goalDetail(goal)){
                                goalRow(goal: goal)
                            }
                        }
                    }
                }
                .id(coordinator.dataVersion)
            }
        }
        .onAppear {
            vm.fetchGoals()
        }
    }
    @ViewBuilder
    private func goalRow(goal: Goal) -> some View {
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

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = GoalsMainViewModel(container: container)
    GoalsMainView(vm: vm)
        .environment(Coordinator())
}

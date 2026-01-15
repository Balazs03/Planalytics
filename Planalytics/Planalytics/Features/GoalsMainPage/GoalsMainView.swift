//
//  GoalsMainPageView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 01..
//

import SwiftUI
internal import CoreData

struct GoalsMainView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: GoalsMainViewModel
    
    init(vm: GoalsMainViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.appBackground, Color.appAccent, Color.appSlate]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    Text("Aktív célok: \(vm.activeGoalNumber)")
                        .contentTransition(.numericText())
                        .animation(.default, value: vm.activeGoalNumber)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    
                    Text("Eddig befejezettek: \(vm.finishedGoalNumber)")
                        .contentTransition(.numericText())
                        .animation(.default, value: vm.finishedGoalNumber)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Button("Hozzáadás") {
                        coordinator.goalPush(.addGoal)
                    }
                    .padding()
                    .buttonStyle(.glass)
                    .fontWeight(.semibold)
                }
                
                VStack {
                    Picker("Szűrés", selection: $vm.selectedFilter) {
                        ForEach(GoalFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if vm.goals.isEmpty {
                        Text("Nincsenek megadott célok")
                    } else {
                        List {
                            ForEach(vm.filteredGoals, id: \.objectID) { goal in
                                NavigationLink(value: Page.goalDetail(goal)){
                                    GoalRowView(goal: goal)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .animation(.default, value: vm.filteredGoals)
                    }
                }
            }
            .padding()
        }
        .onChange(of: coordinator.dataVersion) {
            withAnimation(.snappy) { // Itt adjuk meg az animációt
                vm.fetchGoals()
            }
        }
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = GoalsMainViewModel(container: container)
    GoalsMainView(vm: vm)
        .environment(Coordinator())
}

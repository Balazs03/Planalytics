//
//  GoalsMainPageView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 01..
//

import SwiftUI
internal import CoreData

struct GoalsMainView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: GoalsMainViewModel
    
    init(vm: GoalsMainViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mainBackground, .textBackground]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 15) {
                    HStack {
                        StaticCardView(text: appLanguage == "hu" ? "Aktív célok": "Active goals", value: String(vm.activeGoalNumber), color: .blue, icon: "target")
                        
                        StaticCardView(text: appLanguage == "hu" ? "Befejezettek": "Completed", value: String(vm.finishedGoalNumber), color: .green, icon: "checkmark.seal.text.page.fill")
                    }
                    
                    Button {
                        coordinator.goalPush(.addGoal)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Új cél hozzáadása")
                        }
                    }
                    .frame(maxWidth: .infinity)
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
                    .padding(.horizontal)
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
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    coordinator.goalPush(.settings)
                } label: {
                    Label("Beállítások", systemImage: "gearshape.fill")
                }
            }
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

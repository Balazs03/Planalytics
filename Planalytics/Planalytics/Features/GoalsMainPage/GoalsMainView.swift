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
    @Environment(\.managedObjectContext) private var viewContext
    
    enum GoalFilter: String, CaseIterable {
        case all
        case active
        case finished
        
        var nameHu: String {
            switch self {
            case .all:
                "Összes"
            case .active:
                "Aktív"
            case .finished:
                "Befejezett"
            }
        }
        
        var nameEn: String {
            switch self {
            case .all:
                "All"
            case .active:
                "Active"
            case .finished:
                "Finished"
            }
        }
    }
    
    @State private var selectedFilter: GoalFilter = .all
    @FetchRequest(sortDescriptors: [SortDescriptor(\.plannedCompletionDate, order: .forward)])
    private var goals: FetchedResults<Goal>
    private var finishedGoalNumber: Int { return goals.filter { $0.isFinished }.count }
    private var activeGoalNumber : Int { return goals.filter { !$0.isDeleted && !$0.isFinished }.count }
    private var filteredGoals: [Goal] {
        switch selectedFilter {
        case .all: return Array(goals)
        case .active: return goals.filter { !$0.isFinished }
        case .finished: return goals.filter { $0.isFinished }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mainBackground, .textBackground]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 15) {
                    HStack {
                        StaticCardView(text: appLanguage == "hu" ? "Aktív célok": "Active goals", value: String(activeGoalNumber), color: .blue, icon: "target")
                        
                        StaticCardView(text: appLanguage == "hu" ? "Befejezettek": "Completed", value: String(finishedGoalNumber), color: .green, icon: "checkmark.seal.text.page.fill")
                    }
                    
                    NavigationLink(value: Page.addGoal) {
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
                    Picker("Szűrés", selection: $selectedFilter) {
                        ForEach(GoalFilter.allCases, id: \.self) { filter in
                            Text(appLanguage == "hu" ? filter.nameHu : filter.nameEn).tag(filter)
                        }
                    }
                    .padding(.horizontal)
                    .pickerStyle(.segmented)
                    
                    if goals.isEmpty {
                        Text("Nincsenek megadott célok")
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredGoals, id: \.objectID) { goal in
                                NavigationLink(value: Page.goalDetail(goal)){
                                    GoalRowView(goal: goal)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .animation(.default, value: filteredGoals)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                
                NavigationLink(value: Page.settings) {
                    Label("Beállítások", systemImage: "gearshape.fill")

                }
            }
        }
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    GoalsMainView()
        .environment(\.managedObjectContext, container.context)
}

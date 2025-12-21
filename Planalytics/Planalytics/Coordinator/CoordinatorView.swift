//
//  CoordinatorView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 20..
//

import SwiftUI

struct CoordinatorView: View {
    @Environment(Coordinator.self) private var coordinator: Coordinator
    let container: CoreDataManager
    
    var body: some View {
        NavigationStack(path: Bindable(coordinator).path) {
            MainPageView(vm: MainPageViewModel(container: container))
        }
    }
    
    @ViewBuilder func viewFactory(_ path: Page) -> some View {
        switch path {
        case .main:
            MainPageView(vm: MainPageViewModel(container: container))
        case .goalsMain:
            GoalsMainPageView(vm: GoalsMainPageViewModel(container: container))
        case .goalDetail(let goal):
            GoalDetailPageView(vm: GoalDetailPageViewModel(goal: goal, container: container))
        case .addGoal:
            AddGoalPageView(vm: AddGoalPageViewModel(container: container))
        case .addTransaction:
            AddTransactionPageView(vm: AddTransactionPageViewModel(container: container))
        }
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    CoordinatorView(container: container)
        .environment(Coordinator())
}

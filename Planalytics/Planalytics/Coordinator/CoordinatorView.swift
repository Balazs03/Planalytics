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
            
                .navigationDestination(for: Page.self) {
                    page in viewFactory(page)
                }
        }
        .sheet(item: Bindable(coordinator).sheet) { sheet in
            sheetFactory(sheet)
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
    
    @ViewBuilder func sheetFactory(_ sheet: Sheet) -> some View {
        switch sheet {
        case .addMoney(let goal):
            let vm = AddMoneySheetViewModel(container: container, goal: goal)
            AddMoneySheet(vm: vm)
        case .withdrawMoney(let goal):
            let vm = WithdrawMoneySheetViewModel(container: container, goal: goal)
            WithdrawMoneySheet(vm: vm)
        }
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    CoordinatorView(container: container)
        .environment(Coordinator())
}

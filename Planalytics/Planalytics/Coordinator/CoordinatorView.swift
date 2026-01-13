//
//  CoordinatorView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 20..
//

import SwiftUI
internal import CoreData

struct CoordinatorView: View {
    @Environment(Coordinator.self) private var coordinator
    let container: CoreDataManager
    
    var body: some View {
        @Bindable var bindableCoordinator = coordinator
        
        TabView (selection: $bindableCoordinator.selectedTab) {
            
            NavigationStack(path: $bindableCoordinator.mainPath) {
                viewFactory(.main)
                    .navigationDestination(for: Page.self) { page in
                        viewFactory(page)
                    }
            }
            .tabItem {
                Label("Pénzügyek", systemImage: "house")
            }
            .tag(Tab.main)
            
            NavigationStack(path: $bindableCoordinator.goalPath) {
                viewFactory(.goalsMain)
                    .navigationDestination(for: Page.self) { page in
                        viewFactory(page)
                    }
            }
            .tabItem {
                Label("Célok", systemImage: "list.bullet")
            }
            .tag(Tab.goals)
        }
        .fontDesign(.rounded)
        .tabViewStyle(.automatic)
        .sheet(item: Bindable(coordinator).sheet) { sheet in
            sheetFactory(sheet)
        }
    }
    
    @ViewBuilder func viewFactory(_ path: Page) -> some View {
        switch path {
        case .main:
            let vm = TransactionMainViewModel(container: container)
            TransactionMainView(vm: vm)
            
        case .goalsMain:
            let vm = GoalsMainViewModel(container: container)
            GoalsMainView(vm: vm)
            
        case .goalDetail(let goal):
            let vm = GoalDetailViewModel(goal: goal, container: container)
            GoalDetailView(vm: vm)
            
        case .addGoal:
            let vm = AddGoalPageViewModel(container: container)
            AddGoalView(vm: vm)
            
        case .addTransaction:
            let vm = AddTransactionViewModel(container: container)
            AddTransactionView(vm: vm)
            
        case .allTransactions:
            let vm = AllTransactionsViewModel(container: container)
            AllTransactionsView(vm: vm)
                .environment(\.managedObjectContext, vm.container.context)
            
        case .transactionStatistics:
            let vm = TransactionStatisticsViewModel(container: container)
            TransactionStatisticsView(vm: vm)
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
        case .statistics(let goal):
            let vm = GoalStatisticsSheetViewModel(container: container, goal: goal)
            GoalStatisticsSheet(vm: vm)
        }
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    CoordinatorView(container: container)
        .environment(Coordinator())
}

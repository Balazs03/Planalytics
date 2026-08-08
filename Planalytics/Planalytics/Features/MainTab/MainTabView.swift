//
//  CoordinatorView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 20..
//

import SwiftUI
internal import CoreData

enum Page: Hashable {
    case goalsMain
    case goalDetail(Goal)
    case main
    case addGoal
    case addTransaction
    case allTransactions(showRecurrentOnly: Bool)
    case transactionStatistics
    case settings
}

enum Tab {
    case main
    case goals
}

enum Sheet: Hashable, Identifiable {
    var id: String {
        switch self {
        case .addMoney(let goal):
            return "addMoney_\(goal.id)"
        case .withdrawMoney(let goal):
            return "withdrawMoney_\(goal.id)"
        case .statistics(let goal):
            return "statics_\(goal.id)"
        case .setPinCode:
            return "setPinCode"
        }
    }
    
    case addMoney(Goal)
    case withdrawMoney(Goal)
    case statistics(Goal)
    case setPinCode
}

struct MainTabView: View {
    let container: CoreDataManager
    @State var mainPath = NavigationPath()
    @State var goalPath = NavigationPath()
    var sheet: Sheet?
    @State var selectedTab: Tab = .main
    
    init(container: CoreDataManager) {
        self.container = container
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Selected icon/text color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.black
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        // Unselected icon/text color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            NavigationStack(path: $mainPath) {
                viewFactory(.main)
                    .navigationDestination(for: Page.self) { page in
                        viewFactory(page)
                    }
            }
            .tabItem {
                Label("Pénzügyek", systemImage: "house")
            }
            .tag(Tab.main)
            
            NavigationStack(path: $goalPath) {
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
    }
    
    @ViewBuilder func viewFactory(_ path: Page) -> some View {
        switch path {
        case .main:
            let vm = TransactionMainViewModel(container: container)
            TransactionMainView(vm: vm)
                .environment(\.managedObjectContext, container.context)

        case .goalsMain:
            let vm = GoalsMainViewModel(container: container)
            GoalsMainView(vm: vm)
                .environment(\.managedObjectContext, container.context)

        case .goalDetail(let goal):
            GoalDetailView(container: container, goal: goal)
                .environment(\.managedObjectContext, container.context)

        case .addGoal:
            AddGoalView(container: container)
                //.environment(\.managedObjectContext, container.context)
            // MAJD HA KICSERÉLEM A CORE DATA OSZTÁLYT
        case .addTransaction:
            AddTransactionView(container: container)
                .environment(\.managedObjectContext, container.context)

        case .allTransactions(let showRecurrentOnly):
            AllTransactionsView(showRecurrentOnly: showRecurrentOnly)
                .environment(\.managedObjectContext, container.context)
            
        case .transactionStatistics:
            let vm = TransactionStatisticsViewModel(container: container)
            TransactionStatisticsView(vm: vm)
                .environment(\.managedObjectContext, container.context)

        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    MainTabView(container: container)
}

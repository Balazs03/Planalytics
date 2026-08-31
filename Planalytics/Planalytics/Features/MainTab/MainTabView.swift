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
    case statistics(Goal)
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
            TransactionMainView()
                .environment(\.managedObjectContext, container.context)

        case .goalsMain:
            GoalsMainView()
                .environment(\.managedObjectContext, container.context)

        case .goalDetail(let goal):
            GoalDetailView(container: container, goal: goal)
                .environment(\.managedObjectContext, container.context)

        case .addGoal:
            AddGoalView()
                .environment(\.managedObjectContext, container.context)
        case .addTransaction:
            AddTransactionView()
                .environment(\.managedObjectContext, container.context)

        case .allTransactions(let showRecurrentOnly):
            AllTransactionsView(showRecurrentOnly: showRecurrentOnly)
                .environment(\.managedObjectContext, container.context)
            
        case .transactionStatistics:
            TransactionStatisticsView()
                .environment(\.managedObjectContext, container.context)

        case .settings:
            SettingsView()
            
        case .statistics(let goal):
            GoalStatisticsSheet(vm: GoalStatisticsSheetViewModel(container: container, goal: goal))
        }
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    MainTabView(container: container)
}

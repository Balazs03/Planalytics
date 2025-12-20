//
//  Coordinator.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 19..
//

import Foundation
import SwiftUI

enum Page: Hashable {
    case goalsMain
    case goalDetail(Goal)
    case main
    case addGoal
    case addTransaction
}

enum Sheet: Hashable {
    case addMoney
    case withdrawMoney
}

@Observable
class Coordinator {
    var path = NavigationPath()
    var sheet: Sheet?
    
    func push(_ page: Page) {
        path.append(page)
    }
    
    func pop(){
        path.removeLast()
    }
    
    func present(sheet: Sheet) {
        self.sheet = sheet
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
}

//
//  AddTransactionViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import Foundation

@Observable
class AddTransactionViewModel {
    let container: CoreDataManager
    
    init(container: CoreDataManager) {
        self.container = container
    }
}

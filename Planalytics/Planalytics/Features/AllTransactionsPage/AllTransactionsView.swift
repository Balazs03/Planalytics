//
//  AllTransactionsViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 31..
//

import SwiftUI
internal import CoreData

struct AllTransactionsView: View {
    @Environment(Coordinator.self) private var coordinator
    // @ miatt ez egy wrapper. 2 propertije van: items és _items
    // Előbbi csak egy "getter", ami mutat az _itemsre, mint egy private value public része
    // Ha a _items nincs inicializálva, hibát dob, mert nincs mire mutatnia
    @SectionedFetchRequest var items: SectionedFetchResults<String, Transaction>
    
    let showRecurrentOnly: Bool
    
    init(showRecurrentOnly: Bool) {
        self.showRecurrentOnly = showRecurrentOnly
        
        let predicate = NSPredicate(format: "isRecurrent == %@", NSNumber(value: showRecurrentOnly))
        
        _items = SectionedFetchRequest(
            sectionIdentifier: \Transaction.sect,
            sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
            predicate: predicate,
            animation: .default
        )
    }
    var body: some View {
        List {
            ForEach(items) { section in
                Section(section.id) {
                    ForEach(section) { item in
                        TransactionRowView(transaction: item)
                    }
                }
            }
        }
        .navigationTitle("Tranzakciók")
    }
}

#Preview {
    let mockManager = CoreDataManager.transactionListPreview()
    AllTransactionsView(showRecurrentOnly: false)
        .environment(Coordinator())
        .environment(\.managedObjectContext, mockManager.context)
}

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
    @Environment(\.managedObjectContext) var viewContext
    // @ miatt ez egy wrapper. 2 propertije van: items és _items
    // Előbbi csak egy "getter", ami mutat az _itemsre, mint egy private value public része
    // Ha a _items nincs inicializálva, hibát dob, mert nincs mire mutatnia
    @SectionedFetchRequest var items: SectionedFetchResults<String, Transaction>
    
    private func deleteTransaction(trans: Transaction) {
        viewContext.delete(trans)
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    let showRecurrentOnly: Bool
    
    init(showRecurrentOnly: Bool) {
        self.showRecurrentOnly = showRecurrentOnly
        
        let predicate = NSPredicate(format: "isRecurrent == %@", NSNumber(value: showRecurrentOnly))
        let currentLange = UserDefaults.standard.string(forKey: "appLanguage") ?? "hu"
        
        if currentLange == "hu" {
            
            _items = SectionedFetchRequest(
                sectionIdentifier: \Transaction.sectHu,
                sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
                predicate: predicate,
                animation: .default
            )
        } else {
            _items = SectionedFetchRequest(
                sectionIdentifier: \Transaction.sectEn,
                sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
                predicate: predicate,
                animation: .default
            )
        }
    }
    
    var body: some View {
        List {
            ForEach(items) { section in
                Section(section.id) {
                    ForEach(section) { item in
                        TransactionRowView(transaction: item)
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteTransaction(trans: item)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
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

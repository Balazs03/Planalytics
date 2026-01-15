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
    @SectionedFetchRequest(
        sectionIdentifier: \Transaction.sect,
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default
    ) private var items

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
    AllTransactionsView()
        .environment(Coordinator())
        .environment(\.managedObjectContext, mockManager.context)
}

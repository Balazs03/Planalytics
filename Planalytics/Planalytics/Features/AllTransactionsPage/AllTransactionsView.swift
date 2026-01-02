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
    @State private var vm: AllTransactionsViewModel
    @SectionedFetchRequest(
        sectionIdentifier: \Transaction.sect,
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default
    ) private var items
    
    init(vm: AllTransactionsViewModel) {
        self.vm = vm
    }

    var body: some View {
        List {
            ForEach(items) { section in
                Section(section.id) {
                    ForEach(section) { item in
                        HStack {
                            Text("Tranzakció: \(item.date, format: .dateTime.year().month().day())")
                            Text("Összeg: \(item.amount)")
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
    let vm = AllTransactionsViewModel(container: mockManager)
    AllTransactionsView(vm: vm)
        .environment(Coordinator())
        .environment(\.managedObjectContext, vm.container.context)
}

//
//  AddTransactionView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm : AddTransactionViewModel
    @State private var isAmountOnFocus: Bool = false
    var disableForm: Bool {
        guard let amount = vm.amount, let name = vm.name else { return true }
        if vm.transactionType == .income {
            return amount == 0
        } else {
            return amount == 0 || name.isEmpty || vm.transactionCategory == nil
        }
    }
    
    init(vm: AddTransactionViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        Form {
            Section("Típus"){
                Picker(selection: $vm.transactionType, label: Text("Válaszd ki a típust")) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Összeg") {
                HStack{
                    TextField("0.0", value: $vm.amount, format: .number)
                        .font(.system(size: 28))
                        .multilineTextAlignment(.center)
                    Text("Ft")
                        .opacity(vm.amount == 0 ? 0.3 : 1)
                        .font(.system(size: 28))
                }
            }
            
            Section("Név") {
                TextField(vm.transactionType == .income ? "Bevétel neve" : "Kiadás neve", text: Binding(
                        get: { vm.name ?? "" }, // Ha nil, akkor üres stringet mutat
                        set: { vm.name = $0.isEmpty ? nil : $0 } // Ha üresre törli, akkor nil legyen (vagy maradhat simán $0 is)
                    )
                )
            }
            
            if vm.transactionType == .expense {
                Section("Kategória") {
                    Picker(selection: $vm.transactionCategory, label: Text("Válaszd ki a kategóriát")) {
                        ForEach(TransactionCategory.allCases) { category in
                            Label {
                                    // A szöveg (title) rész - itt feketén hagyjuk vagy kényszerítjük
                                    Text(category.title)
                                        .foregroundStyle(.black)
                                } icon: {
                                    // Az ikon rész - itt alkalmazzuk a kategória színét
                                    Image(systemName: category.iconName)
                                        .foregroundStyle(category.diagramColor)
                                }
                                .tag(category as TransactionCategory?)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            
            Button("Mentés") {
                vm.saveTransaction()
                coordinator.mainPop()
            }
            .disabled(disableForm)
        }
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    let vm = AddTransactionViewModel(container: container)
    AddTransactionView(vm: vm)
        .environment(Coordinator())
}

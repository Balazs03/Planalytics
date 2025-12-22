//
//  AddTransactionView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI

struct AddTransactionPageView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm : AddTransactionPageViewModel
    @State private var isAmountOnFocus: Bool = false
    var disableForm: Bool {
        if vm.transactionType == .income {
            vm.amount == 0
        } else {
            vm.amount == 0 || vm.name.isEmpty || (vm.transactionCategory == nil)
        }
    }
    
    init(vm: AddTransactionPageViewModel) {
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
                TextField(vm.transactionType == .income ? "Bevétel neve" : "Kiadás neve", text: $vm.name)
            }
            
            if vm.transactionType == .expense {
                Section("Kategória") {
                    Picker(selection: $vm.transactionCategory, label: Text("Válaszd ki a kategóriát")) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(category.diagramColor)
                                Text(category.title)
                                
                            }
                        }
                    }
                }
            }
            
            Button("Mentés") {
                if vm.transactionType == . income && vm.name.isEmpty {
                    vm.name = "Névtelen bevétel"
                }
                
                vm.saveTransaction()
                
                coordinator.pop()
            }
            .disabled(disableForm)
        }
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    let vm = AddTransactionPageViewModel(container: container)
    AddTransactionPageView(vm: vm)
        .environment(Coordinator())
}

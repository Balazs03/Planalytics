//
//  AddTransactionView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI

struct AddTransactionView: View {
    @State private var vm : AddTransactionViewModel
    @State private var isAmountOnFocus: Bool = false
    
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
                    .pickerStyle(.inline)
                }
            }
        }
    }
}

#Preview {
    AddTransactionView(
        vm: AddTransactionViewModel(
            container: CoreDataManager.transactionListPreview()
        )
    )
}

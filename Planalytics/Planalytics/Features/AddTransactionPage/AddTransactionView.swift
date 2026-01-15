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
            return amount == 0 || name.isEmpty || vm.transactionCategory == nil || amount > vm.transBalance
        }
    }
    
    init(vm: AddTransactionViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.appBackground, Color.appAccent]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            VStack {
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
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("Ft")
                                .opacity(vm.amount != nil ? 1 : 0.3)
                                .font(.title)
                        }
                        
                        if let amount = vm.amount, amount > vm.transBalance, vm.transactionType == .expense {
                            Label{
                                Text("Az adott összeg meghaladja a jelenlegi egyenleget")
                            }icon: {
                                Image(systemName: "exclamationmark.triangle.fill")
                            }
                            .foregroundStyle(.red)
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
                }
                .scrollContentBackground(.hidden)
                .tint(.appSlate)
                .fontDesign(.rounded)
                
                Button {
                    vm.saveTransaction()
                    coordinator.mainPop()
                } label: {
                    Text("Mentés")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity) // Teljes szélesség
                        .padding()
                        // Ha le van tiltva, szürke, ha aktív, akkor az appAccent szín
                        .background(disableForm ? Color.appSlate.opacity(0.5) : Color.appSlate)
                        .cornerRadius(16)
                        .shadow(color: disableForm ? .clear : Color.appAccent.opacity(0.4), radius: 8, y: 4)
                }
                .padding()
                .disabled(disableForm)
            }
        }
        .navigationTitle("Új tranzakció")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    let vm = AddTransactionViewModel(container: container)
    AddTransactionView(vm: vm)
        .environment(Coordinator())
}

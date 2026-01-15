//
//  AddMoneySheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 14..
//

import SwiftUI
internal import CoreData

struct AddMoneySheet: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: AddMoneySheetViewModel
    @State private var showAmountAlert: Bool = false
    
    init(vm: AddMoneySheetViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                HStack{
                    TextField("0.0", value: $vm.amount, format: .number)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    Text("Ft")
                        .opacity(vm.amount == nil ? 0.3 : 1)
                        .font(.largeTitle)
                }
                
                if let amount = vm.amount {
                    HStack{
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("A kívánt összeg meghaladja a jelenlegi egyenleget")
                            .foregroundColor(.red)
                    }
                    .opacity(amount > vm.transBalance as Decimal ? 1 : 0)
                }
                
                Text("Egyenleg: \(vm.transBalance.formatted()) Ft")
                
                Button("Pénz hozzáadása") {
                    if let amount = vm.amount, amount > vm.goal.amount as Decimal {
                        showAmountAlert.toggle()
                    } else {
                        vm.addBalance()
                        coordinator.dismissSheet()
                    }
                }
                .padding()
                .buttonStyle(.glass)
                .fontWeight(.semibold)
                .disabled(!vm.addBalancePossible())
            }
            .alert("Túl nagy összeg", isPresented: $showAmountAlert) {
                Button("OK", role: .cancel){
                    vm.addBalance()
                    coordinator.dismissSheet()
                }
                Button("Mégsem", role: .destructive) {
                    showAmountAlert.toggle()
                }
            } message: {
                Text("A megadott összeg meghaladja a cél összegét")
            }
            
            
            .navigationTitle("Pénz hozzáadása")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        coordinator.dismissSheet()
                    } label: {
                        Image(systemName: "arrow.backward")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(vm.goal.iconName ?? "")
                }
            }
        }
        .fontDesign(.rounded)
        .padding()
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = AddMoneySheetViewModel(container: container, goal: container.fetchGoals()[0])
    AddMoneySheet(
        vm: vm
    )
    .environment(Coordinator()) // Inject the coordinator to avoid crashing
}

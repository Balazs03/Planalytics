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
                        .opacity(vm.amount == 0 ? 0.3 : 1)
                        .font(.largeTitle)
                }
                
                HStack{
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text("A kívánt összeg meghaladja a jelenlegi egyenleget")
                        .foregroundColor(.red)
                }
                .opacity(vm.addBalancePossible() ? 0: 1)
                
                Text("Egyenleg: \(vm.transBalance.formatted()) Ft")
                
                Button("Pénz hozzáadása") {
                    vm.addBalance()
                    coordinator.dismissSheet()
                }
                .buttonStyle(.glassProminent)
                .disabled(!vm.addBalancePossible() || vm.amount <= 0)
            }
            .navigationTitle("Pénz hozzáadása")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        coordinator.dismissSheet()
                    } label: {
                        Image(systemName: "arrow.backward")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
        .padding()
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = AddMoneySheetViewModel(container: container, goal: container.fetchGoals()[1])
    AddMoneySheet(
        vm: vm
    )
    .environment(Coordinator()) // Inject the coordinator to avoid crashing
}

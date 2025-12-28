//
//  WithdrawMoneySheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 14..
//

import SwiftUI

struct WithdrawMoneySheet: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: WithdrawMoneySheetViewModel
    
    init(vm: WithdrawMoneySheetViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center){
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
                    Text("Az kívánt összeg meghaladja a célre félretett összeget")
                        .foregroundColor(.red)
                }
                .opacity(vm.withdrawBalancePossible() ? 0: 1)
                
                Text("Eddig a célre féltetett összeg: \(vm.goal.amount) Ft")
                
                Button("Pénz kivétele") {
                    vm.withdrawBalance()
                    coordinator.dismissSheet()
                }
                .disabled(!vm.withdrawBalancePossible() || vm.amount == 0)
                .buttonStyle(.glassProminent)
            }
            .navigationTitle("Pénz kivétel")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button{
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
        .padding()
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = WithdrawMoneySheetViewModel(container: container, goal: container.fetchGoals()[0])
    WithdrawMoneySheet(
        vm: vm
    )
    .environment(Coordinator()) // Inject the coordinator to avoid crashing
}

//
//  GoalDetailView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import SwiftUI
internal import CoreData

struct GoalDetailPageView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: GoalDetailPageViewModel
    @State private var showAddMoneySheet = false
    @State private var showWithdrawSheet = false
    
    init(vm : GoalDetailPageViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack{
            Text(vm.goal.name)
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Text("\((vm.goal.progress).formatted())%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            LinearProgressView(value: NSDecimalNumber(decimal: vm.goal.progress).doubleValue, shape: Capsule())
                        .tint(Gradient(colors: [.purple, .blue]))
                        .frame(height: 64)
        }
        .padding()

        HStack {
            VStack {
                Button {
                    showAddMoneySheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
                Text("Pénz hozzáadása")
            }
            
            VStack {
                Button {
                    showWithdrawSheet = true
                } label: {
                    Image(systemName: "arrow.down")
                }
                .buttonStyle(.glassProminent)
                Text("Pénz kivétele")
            }
        }
        .padding()
        
        if let description = vm.goal.desc {
            Section("Leírás") {
                Text(description)
            }
        }
        
        Text("Eddig féltetett pénz: \(vm.goal.saving ?? 0.00)")
        
        Text("Tervezett befejezési dátum: \(vm.goal.plannedCompletionDate.formatted(date: .numeric, time: .omitted))")
        
        Text("Létrehozva: \(vm.goal.creationDate.formatted(date: .numeric, time: .omitted))")
        
        Toggle("Befejezett", isOn: Binding(
            get: { vm.goal.isFinished },
            set: {
                vm.goal.isFinished = $0
                vm.container.saveContext()
            }
        ))
        .sheet(isPresented: $showAddMoneySheet) {
            AddMoneySheet(
                isAddPossible: {
                    amount in
                    vm.addBalancePossible(amount: amount)
                }, addMoney: {
                    amount in
                    vm.addBalance(amount: amount)
                }, balance: vm.transBalance
            )
        }
        .sheet(isPresented: $showWithdrawSheet) {
            WithdrawMoneySheet(
                isWithdrawPossible: {
                    amount in
                    vm.withdrawBalancePossible(amount: amount)
                },
                withdrawMoney: {
                    amount in
                    vm.withdrawBalance(amount: amount)
                },
                goalBalance: vm.goal.saving?.decimalValue ?? 0.00,
            )
        }
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = GoalDetailPageViewModel(goal: container.fetchGoals()[0], container: container)
    GoalDetailPageView(vm: vm)
        .environment(Coordinator())
}

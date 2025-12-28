//
//  GoalDetailView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import SwiftUI
internal import CoreData

struct GoalDetailView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: GoalDetailViewModel
    
    init(vm : GoalDetailViewModel) {
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
                    coordinator.present(sheet: .addMoney(vm.goal))
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
                Text("Pénz hozzáadása")
            }
            
            VStack {
                Button {
                    coordinator.present(sheet: .withdrawMoney(vm.goal))
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
            set: { newValue in
                vm.goal.isFinished = newValue
                vm.container.saveContext() // Azonnali mentés a Toggle átváltásakor
            }
        ))
        
        Button("Törlés") {
            vm.deleteGoal()
            coordinator.goalPop()
        }
        .buttonStyle(.borderedProminent)
        
        .navigationTitle(vm.goal.name)
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = GoalDetailViewModel(goal: container.fetchGoals()[0], container: container)
    GoalDetailView(vm: vm)
        .environment(Coordinator())
}

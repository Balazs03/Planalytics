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
        VStack {
            Text(vm.goal.name)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            
            Text("Tervezett összeg: \(vm.goal.amount) Ft")
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("\((vm.goal.progress * 100).formatted())%")
                .font(.system(.title, design: .rounded, weight: .bold))

            LinearProgressView(value: NSDecimalNumber(decimal: vm.goal.progress).doubleValue, shape: Capsule())
                        .tint(Gradient(colors: [.purple, .blue]))
                        .frame(height: 64)
        }

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
        
        .buttonStyle(.borderedProminent)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // Törlés gomb a menüben
                    Button(role: .destructive) {
                        coordinator.goalPop()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            vm.deleteGoal()
                        }
                    } label: {
                        Label("Cél törlése", systemImage: "trash")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    let vm = GoalDetailViewModel(goal: container.fetchGoals()[0], container: container)
    NavigationStack {
        GoalDetailView(vm: vm)
            .environment(Coordinator())
    }
}

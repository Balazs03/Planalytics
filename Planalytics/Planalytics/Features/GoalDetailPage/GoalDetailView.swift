//
//  GoalDetailView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import SwiftUI
internal import CoreData
import Charts

struct GoalDetailView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm: GoalDetailViewModel
    
    init(vm : GoalDetailViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [.appBackground, .appSlate], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 25) {
                    
                    VStack(spacing: 10) {
                        Text(vm.goal.name)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Tervezett összeg: \((vm.goal.amount as Decimal).formatted(.number.precision(.fractionLength(2)))) Ft")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        VStack {
                            Text("\((vm.goal.progress * 100).formatted(.number.precision(.fractionLength(2)))) %")
                                .font(.system(.title, design: .rounded, weight: .bold))
                            
                            LinearProgressView(value: NSDecimalNumber(decimal: vm.goal.progress).doubleValue, shape: Capsule())
                                .tint(Gradient(colors: [.blue, .appAccent]))
                                .frame(height: 64)
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 40) {
                        ActionButtonView(label: "Hozzáadás", icon: "plus", action: {
                            coordinator.present(sheet: .addMoney(vm.goal))
                        })
                        
                        ActionButtonView(label: "Kivétel", icon: "arrow.down", action: {
                            coordinator.present(sheet: .withdrawMoney(vm.goal))
                        })
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        if let description = vm.goal.desc {
                            InfoGroupView(label: "Leírás", value: description)
                            Divider()
                            
                        }
                        
                        InfoRowView(label: "Eddig félretett pénz" , value: "\((vm.goal.saving as Decimal? ?? 0.00).formatted()) Ft")
                        
                        InfoRowView(label: "Tervezett befejezési dátum",
                                    value: "\(vm.goal.plannedCompletionDate.formatted(date: .numeric, time: .omitted))")
                        
                        InfoRowView(label: "Létrehozva",
                                    value: "\(vm.goal.creationDate.formatted(date: .numeric, time: .omitted))")
                        
                        Toggle("Befejezett", isOn: Binding(
                            get: { vm.goal.isFinished },
                            set: { newValue in
                                vm.goal.isFinished = newValue
                                vm.container.saveContext() // Azonnali mentés a Toggle átváltásakor
                            }
                        ))
                        .padding(.top)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
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
                        ToolbarItem(placement: .automatic) {
                            Button {
                                coordinator.present(sheet: .statistics(vm.goal))
                            } label: {
                                Image(systemName: "chart.bar.fill")
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: coordinator.dataVersion) {
            withAnimation(.snappy) {
                vm.refreshData()
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

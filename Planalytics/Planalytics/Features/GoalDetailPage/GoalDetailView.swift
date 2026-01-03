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
        ScrollView {
            VStack(spacing: 25) {
                
                VStack(spacing: 10) {
                    Text(vm.goal.name)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Tervezett összeg: \((vm.goal.amount as Decimal).formatted()) Ft")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    VStack {
                        Text("\((vm.goal.progress * 100).formatted())%")
                            .font(.system(.title, design: .rounded, weight: .bold))
                        
                        LinearProgressView(value: NSDecimalNumber(decimal: vm.goal.progress).doubleValue, shape: Capsule())
                            .tint(Gradient(colors: [.purple, .blue]))
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
                
                if let transactions = vm.transactionHistory {
                    
                    VStack(alignment: .leading) {
                        Text("Megtakarítási trend")
                            .font(.headline)
                        
                        Chart {
                            ForEach(transactions) { transaction in
                                LineMark(x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                                         y: .value("Összeg", transaction.total))
                                .foregroundStyle(.pink)
                                
                                AreaMark(x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                                         y: .value("Összeg", transaction.total))
                                .foregroundStyle(.pink)
                                .opacity(0.3)
                                PointMark(
                                    x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                                    y: .value("Összeg", transaction.total)
                                )
                            }
                        }
                        .chartXAxis {
                            if vm.distinctDates > 5 {
                                AxisMarks(values: .stride(by: .month)) { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month())
                                }
                            } else {
                                AxisMarks(values: .stride(by: .day)) { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.year().month().day())
                                }
                            }
                        }
                        if let firstDate = transactions.first?.date {
                            InfoRowView(label: "Első megtaktarítás",
                                        value: "\(firstDate.formatted(date: .numeric, time: .omitted))")
                        }
                        
                        if let lastDate = transactions.last?.date,
                            lastDate != transactions.first?.date {
                            InfoRowView(label: "Utolsó megtakarítás",
                                        value: "\(lastDate.formatted(date: .numeric, time: .omitted))")
                        }
                        
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    if let description = vm.goal.desc {
                        InfoGroupView(label: "Leírás", value: description)
                        Divider()

                    }
                    
                    InfoRowView(label: "Eddig félretett pénz" , value: "\((vm.goal.saving as Decimal? ?? 0.00).formatted())")
                    
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

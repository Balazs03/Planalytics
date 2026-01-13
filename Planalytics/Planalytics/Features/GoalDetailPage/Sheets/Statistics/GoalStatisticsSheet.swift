//
//  StatisticsSheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 09..
//

import SwiftUI
import Charts

struct GoalStatisticsSheet: View {
    @Environment(Coordinator.self) var coordinator
    @State private var vm: GoalStatisticsSheetViewModel
    
    init(vm: GoalStatisticsSheetViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    if let dailyTransactions = vm.dailyTransactions, let monthlyTransactions = vm.monthlyTransactions, let yearlyTransactions = vm.yearlyTransactions {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Megtakarítási trend")
                                .font(.headline)
                            
                            switch vm.selectedFilter {
                            case .daily:
                                GoalChart(transactions: dailyTransactions, vm: vm)
                                    .frame(minHeight: 200)
                            case .monthly:
                                GoalChart(transactions: monthlyTransactions, vm: vm)
                                    .frame(minHeight: 200)
                            case .yearly:
                                GoalChart(transactions: yearlyTransactions, vm: vm)
                                    .frame(minHeight: 200)
                            }
                            
                            Picker("Szűrés", selection: $vm.selectedFilter) {
                                ForEach(ChartDateFilter.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            
                            // INFO SOROK
                            Divider()
                            if let firstDate = dailyTransactions.first?.date {
                                InfoRowView(label: "Első megtakarítás", value: firstDate.formatted(date: .numeric, time: .omitted)
                                )
                            }
                            if let lastDate = dailyTransactions.last?.date {
                                InfoRowView(label: "Utolsó megtakarítás", value: lastDate.formatted(date: .numeric, time: .omitted)
                                )
                            }
                            
                            if let saving = vm.goal.saving, saving.doubleValue < vm.goal.amount.doubleValue {
                                if let lower = vm.predictionBoundaries.last,
                                   let upper = vm.predictionBoundaries.first  {
                                    HStack {
                                        Text("Becsült befejezés")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text("\(lower.formatted(date: .numeric, time: .omitted)) - \(upper.formatted(date: .numeric, time: .omitted))")
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    
                                    if vm.goal.plannedCompletionDate > upper {
                                        Label {
                                            Text("Az eddigi megtakarítsi trend alapján a cél a tervezett dátum után fog teljesülni")
                                        } icon: {
                                            Image(systemName: "exclamationmark.circle")
                                                .foregroundStyle(.yellow)
                                        }

                                    } else if vm.goal.plannedCompletionDate > lower {
                                        Label {
                                            Text("Az eddigi megtakarítási trend alapján a cél a tervezett időn belül teljesülhet")
                                        } icon: {
                                            Image(systemName: "checkmark.circle")
                                                .foregroundStyle(.green)
                                        }

                                    }
                                    
                                    else {
                                        Label {
                                            Text("Az eddigi megtakarítási trendet követve a cél a tervezett dátum előtt teljesülhet")
                                                .foregroundStyle(.secondary)
                                        } icon: {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundStyle(.blue)
                                        }

                                    }
                                }
                            }
                            
                            if vm.distinctDates >= 1 {
                                Text("\(vm.distinctDates) különböző alkalommal történt feltöltés")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Még nem történt feltöltés")
                            }
                        }
                        .padding()
                        .background(Color.appBackground.grayscale(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                    }
                    
                    // FIGYELMEZTETŐ SZÖVEG (A kártyán kívül)
                    if vm.distinctDates < 7 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("A becsléshez tölts fel még \(7 - vm.distinctDates) különböző nap tranzakciókat")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        
                        if let monthySavingPlan = vm.calculaterequiredMonthlySaving(), !monthySavingPlan.isNaN  {
                            StaticCardView(text: "Szükséges havi összeg a célért", value: "\(monthySavingPlan.formatted(.number.precision(.fractionLength(2)))) Ft")
                        }
                        
                        if let maxTransactionAmount = vm.maxTransactionAmount {
                            StaticCardView(text: "Legnagyobb megtakarítás", value: "\(maxTransactionAmount.formatted(.number.precision(.fractionLength(2)))) Ft")
                        }
                        
                        if let remainingDays = vm.daysUntilCompletion, remainingDays > 0 {
                            StaticCardView(text: "Hátravévő napok", value: "\(remainingDays)")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .fontDesign(.rounded)
            .navigationTitle("Statisztikák")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: coordinator.dismissSheet) {
                        Image(systemName: "arrow.backward")
                    }
                }
            }
        }
    }
}

#Preview {
    let inMemoryContainer = CoreDataManager.goalsListPreview()
    let vm = GoalStatisticsSheetViewModel(container: inMemoryContainer, goal: inMemoryContainer.fetchGoals().first!)
    GoalStatisticsSheet(vm : vm)
        .environment(Coordinator())
}

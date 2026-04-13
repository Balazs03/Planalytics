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
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    
    init(vm: GoalStatisticsSheetViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 10) {
                        Text("Megtakarítási trend")
                            .font(.headline)
                        
                        switch vm.selectedFilter {
                        case .daily:
                            if let firstYear = vm.firstYear {
                                YearMonthSelection(selectedYear: $vm.selectedYear, selectedMonth: $vm.selectedMonth, firstYear: firstYear)
                            }
                            GoalChart(transactions: vm.filteredTransactions ?? [], vm: vm)
                                .frame(minHeight: 200)
                        case .monthly:
                            GoalChart(transactions: vm.monthlyTransactions ?? [], vm: vm)
                                .frame(minHeight: 200)
                        case .yearly:
                            GoalChart(transactions: vm.yearlyTransactions ?? [], vm: vm)
                                .frame(minHeight: 200)
                        }
                        
                        Picker("Szűrés", selection: $vm.selectedFilter) {
                            ForEach(ChartDateFilter.allCases, id: \.self) { filter in
                                Text(appLanguage == "hu" ? filter.nameHu : filter.nameEn).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        
                        // INFO SOROK
                        Divider()
                        if let firstDate = vm.dailyTransactions?.first?.date {
                            let label = appLanguage == "hu" ? "Első megtakarítás" : "First saving"
                            InfoRowView(label: label, value: firstDate.formatted(date: .numeric, time: .omitted)
                            )
                        }
                        if let lastDate = vm.dailyTransactions?.last?.date {
                            let label = appLanguage == "hu" ? "Utolsó megtakarítás" : "Last saving"
                            InfoRowView(label: label, value: lastDate.formatted(date: .numeric, time: .omitted)
                            )
                            Divider()
                        }
                        
                        if let saving = vm.goal.saving, saving.doubleValue < vm.goal.amount.doubleValue, let predictions = vm.predictionBoundaries {
                            if let lower = predictions.min(),
                               let upper = predictions.max()  {
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
                                        Text("Az eddigi megtakarítási trend alapján a cél a tervezett dátum után fog teljesülni")
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
                    .background(.secondaryBackground.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                    
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
                        
                        if let monthlySaving = vm.monthlySavingplan  {
                            let text = appLanguage == "hu" ? "Szükséges havi összeg a cél eléréséért": "Monthly amount needed to achieve the goal"
                            StaticCardView(text: text, value: "\(monthlySaving.formatted(.number.precision(.fractionLength(2)))) Ft")
                        }
                        let text = appLanguage == "hu" ? "Hátralévő napok" : "Remaining days"
                        StaticCardView(text: text, value: "\(vm.daysUntilCompletion > 0 ? vm.daysUntilCompletion: 0 )")

                        if let maxTransactionAmount = vm.maxTransactionAmount {
                            let text = appLanguage == "hu" ? "Eddig fetöltött legnagyobb összeg" : "Largest amount saved so far"
                            StaticCardView(text: text, value: "\(maxTransactionAmount.formatted()) Ft")

                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
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

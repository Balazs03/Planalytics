//
//  SwiftUIView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 09..
//

import SwiftUI
import Charts

struct GoalChart: View {
    @State private var selectedDate: Date?
    var selectedTransHolder: transHolder? {
        guard let date = selectedDate else { return nil }
        return transactions.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
    }
    
    let transactions: [transHolder]
    private var vm: GoalStatisticsSheetViewModel
        
    init(transactions: [transHolder], vm: GoalStatisticsSheetViewModel) {
        self.transactions = transactions
        self.vm = vm
    }
    
    var body: some View {
        Chart {
            
            if let selectedTransHolder {
                RuleMark(
                    x: .value("Dátum", selectedTransHolder.date)
                )
                .annotation(overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))) {
                    VStack{
                        Text("\(selectedTransHolder.date.formatted(date: .numeric, time: .omitted))")
                        Text("Összeg")
                        Text("\(selectedTransHolder.total.formatted()) Ft")
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.appText)
                    .shadow(radius: 2)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
            }
            ForEach(transactions) { transaction in
                LineMark(
                    x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                    y: .value("Összeg", transaction.total)
                )
                .foregroundStyle(by: .value("Típus", "Tényleges"))
                
                AreaMark(
                    x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                    y: .value("Összeg", transaction.total)
                )
                .foregroundStyle(by: .value("Típus", "Tényleges"))
                .opacity(0.3)

                PointMark(
                    x: .value("Dátum", Calendar.current.startOfDay(for: transaction.date)),
                    y: .value("Összeg", transaction.total)
                )
                .symbolSize(100)
                .foregroundStyle(.blue)
                .opacity(selectedDate == nil || selectedTransHolder?.date == transaction.date ? 1 : 0.3)

            }
            
            if let saving = vm.goal.saving, saving.doubleValue < vm.goal.amount.doubleValue, vm.distinctDates > 7 {
                ForEach(vm.predictedDates) { pred in
                    LineMark(
                        x: .value("Dátum", pred.date) ,
                        y: .value("Összeg", pred.total)
                    )
                    .foregroundStyle(by: .value("Típus", "Becsült"))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5,5]))
                    
                    if pred.total == vm.goal.amount as Decimal {
                        PointMark(
                            x: .value("Dátum", pred.date),
                            y: .value("Összeg", pred.total)
                        )
                        .foregroundStyle(by: .value("Típus", "Tényleges"))
                    }
                }
            }
        }
        .chartForegroundStyleScale(
            vm.distinctDates > 7 ? ["Tényleges": Color.appSlate, "Becsült": Color.appAccent] :
                ["Tényleges": Color.appSlate]
        )
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: vm.selectedFilter.axisLength)
        .chartXSelection(value: $selectedDate)
        .chartYScale(domain: 0...max(((vm.goal.amount).decimalValue * 1.2), ((vm.goal.saving)?.decimalValue ?? 1) * 1.2, (vm.maxGoalSaving)))
        .chartXAxis {
            AxisMarks(values: .stride(by: vm.selectedFilter.date)) { value in
                if let date = value.as(Date.self) {
                    let components = Calendar.current.dateComponents([.day, .month, .year, .hour], from: date)
                    AxisValueLabel {
                        VStack(alignment: .leading) {
                            if value.index == 0 {
                                Text(date, format: .dateTime.day())
                                Text(date, format: .dateTime.month())
                                Text(date, format: .dateTime.year())
                            } else {
                                switch vm.selectedFilter {
                                case .daily:
                                    Text(date, format: .dateTime.day())
                                    
                                    if components.day == 1 && (value.index > 1 || value.index > 4) {
                                        Text(date, format: .dateTime.month())
                                        if components.month == 1 {
                                            Text(date, format: .dateTime.year())
                                        }
                                    }
                                case .monthly:
                                    Text(date, format: .dateTime.month())
                                    
                                    if components.month == 1 && (value.index > 1 || value.index > 4){
                                        Text(date, format: .dateTime.year())
                                    }
                                case .yearly:
                                    Text(date, format: .dateTime.year())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let inMemoryContainer = CoreDataManager.goalsListPreview()
    let vm = GoalStatisticsSheetViewModel(container: inMemoryContainer, goal: inMemoryContainer.fetchGoals().first!)
    GoalChart(transactions: vm.dailyTransactions!, vm: vm)
}

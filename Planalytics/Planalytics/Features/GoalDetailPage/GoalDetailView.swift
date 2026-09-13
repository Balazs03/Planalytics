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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    
    @State private var activeSheet: ActiveSheet?
    @ObservedObject var goal: Goal
    
    enum ActiveSheet: Identifiable, Hashable {
        var id: Int { hashValue }
        
        case addMoney(Goal)
        case withdrawMoney(Goal)
    }
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [.textBackground, .mainBackground], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 25) {
                    
                    VStack(spacing: 10) {
                        Text(goal.name)
                            .font(.system(.largeTitle, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Tervezett összeg: \((goal.amount as Decimal).formatted(.number.precision(.fractionLength(2)))) Ft")
                            .font(.system(.title2, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        VStack {
                            Text("\((goal.progress * 100).formatted(.number.precision(.fractionLength(2)))) %")
                                .font(.system(.title, weight: .bold))
                            
                            LinearProgressView(value: NSDecimalNumber(decimal: goal.progress).doubleValue, shape: Capsule())
                                .tint(Gradient(colors: [.mainBackground, .secondaryBackground]))
                                .frame(height: 64)
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 40) {
                        ActionButtonView(label: appLanguage == "hu" ? "Hozzáadás" : "Add", icon: "plus", action: {
                            activeSheet = .addMoney(goal)
                        })
                        
                        ActionButtonView(label: appLanguage == "hu" ? "Kivétel" : "Withdraw", icon: "arrow.down", action: {
                            activeSheet = .withdrawMoney(goal)
                        })
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        if let description = goal.desc {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Leírás")
                                    .font(.headline)
                                Text(description)
                                    .font(.body)
                            }
                            Divider()
                        }
                        
                        InfoRowView(label: appLanguage == "hu" ? "Eddig félretett pénz" : "Money saved so far", value: "\((goal.saving as Decimal? ?? 0.00).formatted()) Ft")
                        
                        InfoRowView(label: appLanguage == "hu" ? "Tervezett befejezési dátum" : "Planned completion date",
                                    value: "\(goal.plannedCompletionDate.formatted(date: .numeric, time: .omitted))")
                        
                        InfoRowView(label: appLanguage == "hu" ? "Létrehozva" : "Created on",
                                    value: "\(goal.creationDate.formatted(date: .numeric, time: .omitted))")
                        
                        Toggle("Befejezett", isOn: Binding(
                            get: { goal.isFinished },
                            set: { newValue in
                                goal.isFinished = newValue
                                do {
                                    try viewContext.save()
                                } catch {
                                    print(error)
                                }
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
                                    dismiss()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        deleteGoal()
                                    }
                                    
                                } label: {
                                    Label("Cél törlése", systemImage: "trash")
                                }
                                
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                        ToolbarItem(placement: .automatic) {
                            NavigationLink(value: Page.statistics(goal)) {
                                Image(systemName: "chart.bar.fill")
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addMoney:
                AddMoneySheet(goal: goal)
                    .environment(\.managedObjectContext, viewContext)
            case .withdrawMoney:
                WithdrawMoneySheet(goal: goal)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    func deleteGoal() {
        if let saving = goal.saving as? Decimal, saving > 0 {
            let newTrans = Transaction(context: viewContext)
            newTrans.amount = goal.saving!
            newTrans.name = "\(goal.name) nevű célra félretett megtakarítás"
            newTrans.date = Date()
            newTrans.transactionType = .income
        }
        viewContext.delete(goal)
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    NavigationStack {
        GoalDetailView(goal: container.fetchGoals().first!)
            .environment(\.managedObjectContext, container.context)
    }
}

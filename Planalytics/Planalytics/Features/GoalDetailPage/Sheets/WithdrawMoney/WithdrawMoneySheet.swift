//
//  WithdrawMoneySheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 14..
//

import SwiftUI
internal import CoreData

struct WithdrawMoneySheet: View {
    @Environment(\.dismiss) private var dismiss
    let container: CoreDataManager
    @ObservedObject var goal: Goal
    @State var amount: Decimal?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 15){
                HStack{
                    TextField("0.0", value: $amount, format: .number)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    Text("Ft")
                        .opacity(amount != nil ? 1 : 0.3)
                        .font(.largeTitle)
                }
                
                if let amount = amount, let saving = goal.saving, amount > saving.decimalValue {
                    HStack{
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("A kívánt összeg meghaladja a célre félretett összeget")
                            .foregroundColor(.red)
                    }
                }
                
                Text("Eddig a célra féltetett összeg: \(((goal.saving?.doubleValue.formatted()) ?? "0")) Ft")
                    .padding()
                
                Button("Pénz kivétel") {
                    withdrawBalance()
                    dismiss()
                }
                .disabled(!withdrawBalancePossible() || amount == 0)
                .padding()
                .buttonStyle(.glass)
                .fontWeight(.semibold)
            }
            .navigationTitle("Pénz kivétel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: goal.iconName ?? "chart.line.text.clipboard")
                }
            }
        }
        .padding()
    }
    
    func withdrawBalancePossible() -> Bool {
        guard let amount else { return false }
        
        if amount <= (goal.saving ?? 0) as Decimal {
            return true
        }
        return false
    }
    
    func withdrawBalance() {
        guard let amount else { return }
        let newTransaction = Transaction(context: container.context)
        newTransaction.amount = amount as NSDecimalNumber
        newTransaction.date = Date()
        newTransaction.name = "Utalás \(goal.name) célból"
        newTransaction.transactionType = .income
        newTransaction.goal = goal
                
        goal.saving = (goal.saving ?? 0) as Decimal - amount as NSDecimalNumber
        container.saveContext()
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    WithdrawMoneySheet(container: container, goal: container.fetchGoals()[0])
}

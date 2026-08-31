//
//  AddMoneySheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 14..
//

import SwiftUI
internal import CoreData

struct AddMoneySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var goal: Goal
    @State private var amount: Decimal?
    @State private var finishedMessage: String?
    @State private var showAmountAlert: Bool = false
    
    private let financeService = FinancialService()
    
    private var transBalance : Decimal {
        financeService.calculateBalance(context: viewContext)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 15) {
                HStack{
                    TextField("0.0", value: $amount, format: .number)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    Text("Ft")
                        .opacity(amount == nil ? 0.3 : 1)
                        .font(.largeTitle)
                }
                
                if let amount = amount, amount > transBalance as Decimal {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("A kívánt összeg meghaladja a jelenlegi egyenleget")
                            .foregroundColor(.red)
                    }
                }
                
                Text("Egyenleg: \(transBalance.formatted()) Ft")
                            
                Text("Teljesítésig hátralévő összeg: \((goal.amount.decimalValue - (goal.saving?.decimalValue ?? 0)).formatted()) Ft")
                
                Button("Pénz hozzáadása") {
                    if let amount = amount, amount > goal.amount as Decimal {
                        showAmountAlert.toggle()
                    } else {
                        addBalance()
                        dismiss()
                    }
                }
                .padding()
                .buttonStyle(.glass)
                .fontWeight(.semibold)
                .alert(isPresented: $showAmountAlert) {
                    Alert(
                        title: Text("Túl nagy összeg"),
                        message: Text("A megadott összeg meghaladja a cél összegét"),
                        primaryButton: .cancel(Text("Cancel")),
                        secondaryButton: .default(
                            Text("Ok"),
                            action: {
                                addBalance()
                                dismiss()
                        })
                    )
                }
                .navigationTitle("Pénz hozzáadása")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading){
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.backward")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName:  goal.iconName ?? "chart.line.text.clipboard")
                    }
                }
            }
        }
        .padding()
    }
    
    func addBalance() {
        guard let amount else { return }
        let newTransaction = Transaction(context: viewContext)
        newTransaction.amount = amount as NSDecimalNumber
        newTransaction.date = Date()
        newTransaction.name = "Megtakarítás feltöltése a következő célra: \(goal.name)"
        newTransaction.transactionCategory = .saving
        newTransaction.transactionType = .expense
        newTransaction.goal = goal // ezzel az inverz kapcsolat miatt belerakom a transactions nssetbe
        // Másik megoldás a generált addTransaction függvénnyel
        newTransaction.transactionCategory = .saving
        
        goal.saving = (goal.saving ?? 0) as Decimal + amount as NSDecimalNumber
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    let container = CoreDataManager.goalsListPreview()
    AddMoneySheet(goal: container.fetchGoals()[0])
        .environment(\.managedObjectContext, container.context)
}

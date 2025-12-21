//
//  AddMoneySheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 14..
//

import SwiftUI

struct AddMoneySheet: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var amount: Decimal = 0
    
    var isAddPossible: (Decimal) -> Bool
    var addMoney: (Decimal) -> Void
    var balance: Decimal
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                TextField("0.0", value: $amount, format: .currency(code: "HUF"))
                    .keyboardType(.decimalPad)
                    .padding()
                    .foregroundColor(amount == 0 ? .gray : .white)
                
                HStack{
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text("A kívánt összeg meghaladja a jelenlegi egyenleget")
                        .foregroundColor(.red)
                }
                .opacity(isAddPossible(amount) ? 0: 1)
                
                Text("Egyenleg: \(balance.formatted()) Ft")
                
                Button("Pénz hozzáadása") {
                    addMoney(amount)
                    //dismiss()
                }
                .buttonStyle(.glassProminent)
                .disabled(isAddPossible(amount))
            }
            .navigationTitle("Pénz hozzáadása")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        //dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
        .padding()
    }
}

#Preview {
    AddMoneySheet(
        isAddPossible: { amount in
            // Dummy logic: allow adding if amount is less than 50,000
            return amount < 50000
        },
        addMoney: { amount in
            print("Added \(amount) to goal")
        },
        balance: 125000.50
    )
    .environment(Coordinator()) // Inject the coordinator to avoid crashing
}

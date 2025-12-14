//
//  AddMoneySheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 14..
//

import SwiftUI

struct AddMoneySheet: View {
    @Environment(\.dismiss) var dismiss
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
                    dismiss()
                }
                .buttonStyle(.glassProminent)
                .disabled(isAddPossible(amount))
            }
            .navigationTitle("Pénz hozzáadása")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        dismiss()
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

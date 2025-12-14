//
//  WithdrawMoneySheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 14..
//

import SwiftUI

struct WithdrawMoneySheet: View {
    @Environment(\.dismiss) var dismiss
    @State var amount: Decimal = 0
    
    var isWithdrawPossible: (Decimal) -> Bool = { _ in true }
    var withdrawMoney: (Decimal) -> Void = { _ in }
    var goalBalance: Decimal = 0
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center){
                TextField("0.00", value: $amount, format: .currency(code: "HUF"))
                    .foregroundColor(amount == 0 ? .gray : .white)
                
                HStack{
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text("Az kívánt összeg meghaladja a célre félretett összeget")
                        .foregroundColor(.red)
                }
                .opacity(isWithdrawPossible(amount) ? 0: 1)
                
                Text("Eddig a célre féltetett összeg: \(goalBalance.formatted()) Ft")
                
                Button("Pénz kivétele") {
                    withdrawMoney(amount)
                    dismiss()
                }
                .disabled(isWithdrawPossible(amount))
                .buttonStyle(.glassProminent)
            }
            .navigationTitle("Pénz kivétel")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                    }

                }
            }
        }
        .padding()
    }
}

#Preview {
    WithdrawMoneySheet()
}

//
//  AddGoalPageView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import SwiftUI
import SFSymbolsPicker

struct AddGoalPageView: View {
    @State private var vm =  AddGoalPageViewModel(container: CoreDataManager.shared)
    @State private var showIconPicker: Bool = false
    
    var body: some View {
        Form {
            Section("Név") {
                TextField("Cél nevének megadása", text: $vm.name)
            }
            
            Section("Összeg") {
                HStack {
                    TextField("0.0", value: $vm.amount, format: .number)
                        .font(.system(size: 28))
                        .multilineTextAlignment(.center)
                    Text("Ft")
                        .font(.system(size: 28))
                        .opacity(vm.amount == 0 ? 0.3 : 1)
                }
            }
            
            Section("Tervezett befejezés") {
                DatePicker(
                    "Tervezett dátum",
                    selection: $vm.plannedCompletionDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
            
            Section("Ikon") {
                VStack{
                    Button("Kiválasztás") {
                        showIconPicker.toggle()
                    }
                    
                    Image(systemName: vm.iconNameWrapper)
                        .font(.system(size: 100))
                        .padding()
                }
            }
        }
        .sheet(isPresented: $showIconPicker) {
            SymbolsPicker(selection: $vm.iconNameWrapper, title: "Válassz egy ikont", searchLabel: "Keresés", autoDismiss: true)
        }
        .padding()
    }
}

#Preview {
    AddGoalPageView()
}

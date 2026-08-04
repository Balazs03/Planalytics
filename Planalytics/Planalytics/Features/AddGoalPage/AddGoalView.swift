//
//  AddGoalPageView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import SwiftUI
import SFSymbolsPicker
internal import CoreData

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    let container: CoreDataManager
    @State private var showIconPicker: Bool = false
    @State private var name: String = ""
    @State private var amount: Decimal?
    @State private var plannedCompletionDate = Date()
    @State private var desc: String?
    @State private var iconName: String?
    private var disableForm: Bool {
        name.isEmpty || amount == nil
    }
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.mainBackground, .textBackground]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            VStack {
                Form {
                    Section {
                        TextField("Cél neve", text: $name)
                    } header: {
                        Text("Név")
                    }
                    
                    Section {
                        HStack {
                            TextField("0.0", value: $amount, format: .number)
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("Ft")
                                .font(.title)
                                .opacity(amount != nil ? 1 : 0.3)
                        }
                    } header: {
                        Text("Összeg")
                    }
                    
                    Section {
                        DatePicker(
                            "Tervezett dátum",
                            selection: $plannedCompletionDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    } header: {
                        Text("Dátum")
                    }
                    
                    Section {
                        HStack {
                            Button("Kiválasztás") {
                                showIconPicker.toggle()
                            }
                            .padding()
                            .buttonStyle(.glass)
                            .fontWeight(.semibold)
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .frame(width: 48, height: 48)
                                    .foregroundStyle(.secondaryBackground)
                                    .shadow(color: .black.opacity(0.7), radius: 2)
                                    
                                Image(systemName: iconName ?? "chart.line.text.clipboard")
                                    .font(.title)

                            }
                        }
                    } header: {
                        Text("Ikon")
                    }
                }
                .fontDesign(.rounded)
                .scrollContentBackground(.hidden)
                .sheet(isPresented: $showIconPicker) {
                    SymbolsPicker(selection: Binding(
                        get: { iconName ?? "" }, // Ha nil, akkor üres stringet mutat
                        set: { iconName = $0.isEmpty ? nil : $0 } // Ha üresre törli, akkor nil legyen (vagy maradhat simán $0 is)
                    ), title: "Válassz egy ikont", searchLabel: "Keresés", autoDismiss: true)
                }
                .padding()
                
                Button {
                    addGoal()
                    dismiss()
                } label: {
                    Text("Mentés")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(disableForm ? .none :  .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        // Ha le van tiltva, szürke, ha aktív, akkor az appAccent szín
                        .background(.secondaryBackground)
                        .cornerRadius(16)
                        .shadow(color: disableForm ? .clear : .secondaryBackground, radius: 8, y: 4)
                }
                .padding()
                .disabled(disableForm)
            }
        }
        .navigationTitle("Új cél")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addGoal() {
        guard let amount else { return }
        let newGoal = Goal(context: container.context)
        newGoal.name = self.name
        newGoal.amount = amount as NSDecimalNumber
        newGoal.plannedCompletionDate = self.plannedCompletionDate
        newGoal.creationDate = Date()
        if let desc = desc {
            newGoal.desc = desc
        }
        newGoal.iconName = self.iconName
        
        container.saveContext()
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    AddGoalView(container: container)
}

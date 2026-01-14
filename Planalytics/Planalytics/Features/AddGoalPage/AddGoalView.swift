//
//  AddGoalPageView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 12. 02..
//

import SwiftUI
import SFSymbolsPicker

struct AddGoalView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm : AddGoalPageViewModel
    @State private var showIconPicker: Bool = false
    
    var disableForm: Bool {
        vm.name.isEmpty || vm.amount == 0
    }
    
    init(vm: AddGoalPageViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color.appBackground, Color.appAccent]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            VStack {
                Form {
                    Section {
                        TextField("Cél nevének megadása", text: $vm.name)
                    } header: {
                        Text("Név")
                            .foregroundStyle(Color.appText)
                    }
                    
                    Section {
                        HStack {
                            TextField("0.0", value: $vm.amount, format: .number)
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("Ft")
                                .font(.title)
                                .opacity(vm.amount != nil ? 1 : 0.3)
                        }
                    } header: {
                        Text("Összeg")
                            .foregroundStyle(Color.appText)
                    }
                    
                    Section {
                        DatePicker(
                            "Tervezett dátum",
                            selection: $vm.plannedCompletionDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
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
                                    .foregroundStyle(Color.appAccent)
                                    .shadow(color: .black.opacity(0.7), radius: 2)
                                    
                                Image(systemName: vm.iconNameWrapper)
                                    .font(.title)

                            }
                        }
                    } header: {
                        Text("Ikon")
                    }
                }
                .tint(.appSlate)
                .fontDesign(.rounded)
                .scrollContentBackground(.hidden)
                .sheet(isPresented: $showIconPicker) {
                    SymbolsPicker(selection: $vm.iconNameWrapper, title: "Válassz egy ikont", searchLabel: "Keresés", autoDismiss: true)
                }
                .padding()
                
                Button {
                    vm.addGoal()
                    coordinator.goalPop()
                } label: {
                    Text("Mentés")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity) // Teljes szélesség
                        .padding()
                        // Ha le van tiltva, szürke, ha aktív, akkor az appAccent szín
                        .background(disableForm ? Color.appSlate.opacity(0.5) : Color.appSlate)
                        .cornerRadius(16)
                        .shadow(color: disableForm ? .clear : Color.appAccent.opacity(0.4), radius: 8, y: 4)
                }
                .padding()
                .disabled(disableForm)
            }
        }
        .navigationTitle("Új cél")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    let vm = AddGoalPageViewModel(container: container)
    AddGoalView(vm: vm)
        .environment(Coordinator())
}

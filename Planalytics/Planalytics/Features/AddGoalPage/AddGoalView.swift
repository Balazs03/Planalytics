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
    
    init(vm: AddGoalPageViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.mainBackground, .textBackground]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            VStack {
                Form {
                    Section {
                        TextField("Cél neve", text: $vm.name)
                    } header: {
                        Text("Név")
                            .foregroundStyle(.black)
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
                            .foregroundStyle(.black)
                    }
                    
                    Section {
                        DatePicker(
                            "Tervezett dátum",
                            selection: $vm.plannedCompletionDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    } header: {
                        Text("Dátum")
                            .foregroundStyle(.black)
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
                                    
                                Image(systemName: vm.iconName ?? "chart.line.text.clipboard")
                                    .font(.title)

                            }
                        }
                    } header: {
                        Text("Ikon")
                            .foregroundStyle(.black)
                    }
                }
                .tint(.appSlate)
                .fontDesign(.rounded)
                .scrollContentBackground(.hidden)
                .sheet(isPresented: $showIconPicker) {
                    SymbolsPicker(selection: Binding(
                        get: { vm.iconName ?? "" }, // Ha nil, akkor üres stringet mutat
                        set: { vm.iconName = $0.isEmpty ? nil : $0 } // Ha üresre törli, akkor nil legyen (vagy maradhat simán $0 is)
                    ), title: "Válassz egy ikont", searchLabel: "Keresés", autoDismiss: true)
                }
                .padding()
                
                Button {
                    vm.addGoal()
                    coordinator.goalPop()
                } label: {
                    Text("Mentés")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(vm.disableForm ? .none :  .black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        // Ha le van tiltva, szürke, ha aktív, akkor az appAccent szín
                        .background(.secondaryBackground)
                        .cornerRadius(16)
                        .shadow(color: vm.disableForm ? .clear : .secondaryBackground, radius: 8, y: 4)
                }
                .padding()
                .disabled(vm.disableForm)
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

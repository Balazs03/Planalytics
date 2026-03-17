//
//  AddTransactionView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI
import PhotosUI

struct AddTransactionView: View {
    @Environment(Coordinator.self) private var coordinator
    @State private var vm : AddTransactionViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    
    init(vm: AddTransactionViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.appBackground, Color.appAccent]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            VStack {
                Form {
                    Section("Típus"){
                        Picker(selection: $vm.transactionType, label: Text("Válaszd ki a típust")) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.title)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    if vm.transactionType == .expense {
                        Section("Kép kiválasztás") {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Kép kiválasztás")
                                    
                                    PhotosPicker(selection: $photosPickerItem, matching: .any(of: [.images, .screenshots])) {
                                        Label("Kiválasztás", systemImage: "photo.fill.on.rectangle.fill")
                                    }
                                }
                                
                                Spacer()
                                
                                if let receiptImage = vm.receiptImage {
                                    Image(uiImage: receiptImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                } else {
                                    Image(systemName: "receipt")
                                }
                            }
                        }
                    }
                    
                    Section("Összeg") {
                        HStack{
                            TextField("0.0", value: $vm.amount, format: .number)
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("Ft")
                                .opacity(vm.amount != nil ? 1 : 0.3)
                                .font(.title)
                        }
                        
                        if let amount = vm.amount, amount > vm.transBalance, vm.transactionType == .expense {
                            Label{
                                Text("Az adott összeg meghaladja a jelenlegi egyenleget")
                            }icon: {
                                Image(systemName: "exclamationmark.triangle.fill")
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    
                    Section("Név") {
                        TextField(vm.transactionType == .income ? "Bevétel neve" : "Kiadás neve", text: Binding(
                                get: { vm.name ?? "" }, // Ha nil, akkor üres stringet mutat
                                set: { vm.name = $0.isEmpty ? nil : $0 } // Ha üresre törli, akkor nil legyen (vagy maradhat simán $0 is)
                            )
                        )
                    }
                    
                    Section("Ismétlés") {
                        
                        VStack {
                            Toggle("Ismétlődő fizetés beállítása", isOn: $vm.isRecurrent)
                            
                            if vm.isRecurrent {
                                VStack {
                                    Picker("Gyakoriság", selection: $vm.recurrencyFrequency) {
                                        ForEach(RecurrenceFrequency.allCases, id: \.id) { frequency in
                                            Text(frequency.rawValue)
                                        }
                                    }
                                    DatePicker("Kezdő dátum", selection: Binding<Date>(
                                        get: {
                                            vm.startDate ?? Date()
                                        }, set: {
                                            vm.startDate = $0
                                        }
                                    ),
                                    in: Date()...,
                                    displayedComponents: [.date]
                                    )
                                }
                            }

                        }
                    }
                    
                    if vm.transactionType == .expense {
                        Section("Kategória") {
                            Picker(selection: $vm.transactionCategory, label: Text("Válaszd ki a kategóriát")) {
                                ForEach(TransactionCategory.allCases) { category in
                                    Label {
                                            // A szöveg (title) rész - itt feketén hagyjuk vagy kényszerítjük
                                            Text(category.title)
                                                .foregroundStyle(.black)
                                        } icon: {
                                            // Az ikon rész - itt alkalmazzuk a kategória színét
                                            Image(systemName: category.iconName)
                                                .foregroundStyle(category.diagramColor)
                                        }
                                        .tag(category as TransactionCategory?)
                                }
                            }
                            .pickerStyle(.inline)
                        }
                    }
                }
                .onChange(of: photosPickerItem, { _, _ in
                    Task {
                        if let photosPickerItem, let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                vm.receiptImage = image
                                vm.recognizeText()
                            }
                        }
                    }
                })
                .scrollContentBackground(.hidden)
                .tint(.appSlate)
                .fontDesign(.rounded)
                
                Button {
                    vm.saveTransaction()
                    coordinator.mainPop()
                } label: {
                    Text("Mentés")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity) // Teljes szélesség
                        .padding()
                        // Ha le van tiltva, szürke, ha aktív, akkor az appAccent szín
                        .background(vm.disableForm ? Color.appSlate.opacity(0.5) : Color.appSlate)
                        .cornerRadius(16)
                        .shadow(color: vm.disableForm ? .clear : Color.appAccent.opacity(0.4), radius: 8, y: 4)
                }
                .padding()
                .disabled(vm.disableForm)
            }
        }
        .navigationTitle("Új tranzakció")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    let vm = AddTransactionViewModel(container: container)
    AddTransactionView(vm: vm)
        .environment(Coordinator())
}

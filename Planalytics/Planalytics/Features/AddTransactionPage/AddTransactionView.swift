//
//  AddTransactionView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI
import PhotosUI

struct AddTransactionView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    @Environment(Coordinator.self) private var coordinator
    @State private var vm : AddTransactionViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    
    init(vm: AddTransactionViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mainBackground, .textBackground]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            VStack {
                Form {
                    Section{
                        Picker(selection: $vm.transactionType, label: Text("Válaszd ki a típust")) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(appLanguage == "hu" ? type.titleHU: type.titleEN)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Típus")
                    }
                    
                    if vm.transactionType == .expense {
                        Section {
                            PhotosPicker(selection: $photosPickerItem, matching: .any(of: [.images, .screenshots])) {
                                if let receiptImage = vm.receiptImage {
                                    // State 1: Image is selected
                                    Image(uiImage: receiptImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 180)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(alignment: .bottomTrailing) {
                                            // Small edit badge in the corner
                                            Image(systemName: "pencil.circle.fill")
                                                .symbolRenderingMode(.multicolor)
                                                .font(.system(size: 32))
                                                .padding(8)
                                                .background(Circle().fill(.white).padding(8))
                                        }
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "doc.viewfinder.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.secondaryBackground)
                                        
                                        Text("Nyugta beolvasása")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Koppints ide a fotó kiválasztásához")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 30)
                                    .background(.thirdBackground.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.white, style: StrokeStyle(lineWidth: 3, dash: [8]))
                                    )
                                }
                            }
                            .buttonStyle(.plain) // Removes default blue tint from text
                            .listRowInsets(EdgeInsets()) // Pushes the card all the way to the edges of the form row
                            .listRowBackground(Color.clear) // Removes the default white form background
                            
                        } header: {
                            Text("Csatolmány")
                        }
                    }
                    
                    Section {
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
                    } header: {
                        Text("Összeg")

                    }
                    
                    Section {
                        TextField(vm.transactionType == .income ? "Bevétel neve" : "Kiadás neve", text: Binding(
                                get: { vm.name ?? "" }, // Ha nil, akkor üres stringet mutat
                                set: { vm.name = $0.isEmpty ? nil : $0 } // Ha üresre törli, akkor nil legyen (vagy maradhat simán $0 is)
                            )
                        )
                    } header: {
                        Text("Név")
                    }
                    
                    Section {
                        VStack {
                            Toggle("Ismétlődő fizetés beállítása", isOn: $vm.isRecurrent)
                            
                            if vm.isRecurrent {
                                VStack {
                                    Picker("Gyakoriság", selection: Binding(
                                        get: {
                                            vm.recurrencyFrequency ?? RecurrenceFrequency.weekly
                                        },
                                        set: { newValue in
                                            vm.recurrencyFrequency = newValue
                                        }
                                    )) {
                                        ForEach(RecurrenceFrequency.allCases, id: \.id) { frequency in
                                            Text(appLanguage == "hu" ? frequency.nameHu: frequency.nameEn).tag(frequency)
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
                    } header: {
                        Text("Ismétlés")
                    }
                    
                    if vm.transactionType == .expense {
                        Section {
                            Picker(selection: $vm.transactionCategory, label: Text("Válaszd ki a kategóriát")) {
                                ForEach(TransactionCategory.allCases) { category in
                                    Label {
                                            Text(appLanguage == "hu" ? category.titleHU : category.titleEN)
                                        } icon: {
                                            // Az ikon rész - itt alkalmazzuk a kategória színét
                                            Image(systemName: category.iconName)
                                                .foregroundStyle(category.diagramColor)
                                        }
                                        .tag(category as TransactionCategory?)
                                }
                            }
                            .pickerStyle(.inline)
                        } header: {
                            Text("Kategória")
                        }
                    }
                }
                .onChange(of: photosPickerItem, {
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
                .fontDesign(.rounded)
                
                Button {
                    vm.saveTransaction()
                    coordinator.mainPop()
                } label: {
                    Text("Mentés")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(vm.disableForm ? .none :  .white)
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

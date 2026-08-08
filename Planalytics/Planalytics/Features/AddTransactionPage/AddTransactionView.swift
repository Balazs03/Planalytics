//
//  AddTransactionView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import SwiftUI
import PhotosUI
internal import CoreData

struct AddTransactionView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    @Environment(\.dismiss) private var dismiss
    // @Environment(\.managedObjectContext) private var viewContext
    @State private var photosPickerItem: PhotosPickerItem?
    
    let container: CoreDataManager
    private let scanner = ReceiptScannerService()
    
    @State private var name : String?
    @State private var amount: Decimal?
    @State private var transactionType: TransactionType = .income
    @State private var transactionCategory: TransactionCategory?
    @State private var recurrencyFrequency: RecurrenceFrequency?
    @State private var startDate: Date?
    @State private var isRecurrent: Bool = false
    @State private var receiptImage: UIImage?
    @State private var recognizedText: String?
    
    private var transBalance: Decimal {
        self.container.calculateTotalBalance()[1]
    }
    
    var disableForm: Bool {
        guard let amount = amount, let name = name else { return true }
        if transactionType == .income {
            return amount == 0
        } else {
            return amount == 0 || name.isEmpty || transactionCategory == nil || amount > transBalance
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mainBackground, .textBackground]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            VStack {
                Form {
                    Section{
                        Picker(selection: $transactionType, label: Text("Válaszd ki a típust")) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(appLanguage == "hu" ? type.titleHU: type.titleEN)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Típus")
                    }
                    
                    if transactionType == .expense {
                        Section {
                            PhotosPicker(selection: $photosPickerItem, matching: .any(of: [.images, .screenshots])) {
                                if let receiptImage = receiptImage {
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
                            TextField("0.0", value: $amount, format: .number)
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("Ft")
                                .opacity(amount != nil ? 1 : 0.3)
                                .font(.title)
                        }
                        
                        if let amount = amount, amount > transBalance, transactionType == .expense {
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
                        TextField(transactionType == .income ? "Bevétel neve" : "Kiadás neve", text: $name.bindOptionalString())
                    } header: {
                        Text("Név")
                    }
                    
                    Section {
                        VStack {
                            Toggle("Ismétlődő fizetés beállítása", isOn: $isRecurrent)
                            
                            if isRecurrent {
                                VStack {
                                    Picker("Gyakoriság", selection: Binding(
                                        get: {
                                            recurrencyFrequency ?? RecurrenceFrequency.weekly
                                        },
                                        set: { newValue in
                                            recurrencyFrequency = newValue
                                        }
                                    )) {
                                        ForEach(RecurrenceFrequency.allCases, id: \.id) { frequency in
                                            Text(appLanguage == "hu" ? frequency.nameHu: frequency.nameEn).tag(frequency)
                                        }
                                    }
                                    DatePicker("Kezdő dátum", selection: Binding<Date>(
                                        get: {
                                            startDate ?? Date()
                                        }, set: {
                                            startDate = $0
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
                    
                    if transactionType == .expense {
                        Section {
                            Picker(selection: $transactionCategory, label: Text("Válaszd ki a kategóriát")) {
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
                                receiptImage = image
                                
                                let textData = try? await scanner.recognizeText(receiptImage: receiptImage)
                                
                                name = textData?.name
                                amount = textData?.amount
                            }
                        }
                    }
                })
                .scrollContentBackground(.hidden)
                .fontDesign(.rounded)
                
                Button {
                    saveTransaction()
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
        .navigationTitle("Új tranzakció")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func saveTransaction() {
        guard let name, let amount else { return }
        let transaction = Transaction(context: container.context)
        if transactionType == .income && name.isEmpty {
            transaction.name = "Névtelen bevétel"
        } else {
            transaction.name = name
        }
        
        if isRecurrent, let recFreq = recurrencyFrequency {
            transaction.recurrenceWrapper = recFreq
        }
        
        transaction.isRecurrent = isRecurrent
        if isRecurrent, startDate == nil {
            transaction.recurrenceStartDate = Date()
        } else {
            transaction.recurrenceStartDate = startDate
        }
        transaction.amount = amount as NSDecimalNumber
        transaction.transactionType = transactionType
        transaction.date = Date()
        
        if transactionType == .expense {
            transaction.transactionCategory = transactionCategory
        }
        
        container.saveContext()
    }
}

#Preview {
    let container = CoreDataManager.transactionListPreview()
    AddTransactionView(container: container)
}

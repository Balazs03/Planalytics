//
//  AddTransactionViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2025. 11. 29..
//

import Foundation
internal import CoreData
import UIKit
import Vision

@Observable
class AddTransactionViewModel {
    let container: CoreDataManager
    var name : String?
    var amount: Decimal?
    var transactionType: TransactionType = .income
    var transactionCategory: TransactionCategory?
    let transBalance: Decimal
    var recurrencyFrequency: RecurrenceFrequency?
    var startDate: Date?
    var isRecurrent: Bool = false
    var receiptImage: UIImage?
    var recognizedText: String?
    
    var disableForm: Bool {
        guard let amount = amount, let name = name else { return true }
        if transactionType == .income {
            return amount == 0
        } else {
            return amount == 0 || name.isEmpty || transactionCategory == nil || amount > transBalance
        }
    }
    
    init(container: CoreDataManager) {
        self.container = container
        _ = container.fetchTransactions(year: nil, month: nil)
        self.transBalance = container.calculateTotalBalance()[1]
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
    
    func recognizeText() {
        guard let cgImage = self.receiptImage?.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedStringArray = observations.compactMap { $0.topCandidates(1).first?.string }
            self.recognizedText = recognizedStringArray.joined(separator: "\n")

            
            DispatchQueue.main.async {
                self.processResults(recognizedStrings: recognizedStringArray)
            }
        }
        
        request.recognitionLanguages = ["hu-HU", "en-US"]
        request.recognitionLevel = .accurate
        Task {
            do {
                try handler.perform([request])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func processResults(recognizedStrings: [String]) {
        self.name = recognizedStrings.first
        let totalIdx = recognizedStrings.firstIndex(where: { $0.localizedCaseInsensitiveContains("total") }) ?? recognizedStrings.firstIndex(where: { $0.localizedCaseInsensitiveContains("összesen") }) ?? recognizedStrings.firstIndex(where: { $0.localizedCaseInsensitiveContains("osszesen") })
        let numbersRegex = /[0-9]+([.,][0-9])?/
        if let totalIdx = totalIdx {
            for idx in totalIdx..<recognizedStrings.count {
                if let match = recognizedStrings[idx].firstMatch(of: numbersRegex) {
                    let extractedString = String(match.output.0)
                    
                    let cleanedString = extractedString.replacingOccurrences(of: ",", with: ".")
                    
                    let finalString = cleanedString.replacingOccurrences(of: " ", with: "")

                    
                    if let number = Decimal(string: finalString) {
                        self.amount = number
                        break
                    } else {
                        continue
                    }
                }
            }
        }
    }
}

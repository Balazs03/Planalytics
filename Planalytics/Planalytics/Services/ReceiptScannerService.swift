//
//  ReceiptScannerService.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 08. 06..
//

import Foundation
import UIKit
import Vision

struct ScannedReceiptData {
    var name : String?
    var amount : Decimal?
}

struct ReceiptScannerService {
    func recognizeText(receiptImage: UIImage?) async throws -> ScannedReceiptData {
        // ensure the image can be converted to a CGImage, otherwise return empty data immediately
        guard let cgImage = receiptImage?.cgImage else { return ScannedReceiptData() }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        // wrap the older callback-based Vision API to support modern async/await
        // this pauses the current async task until we call 'continuation.resume()'
        return try await withCheckedThrowingContinuation { continuation in
            // define the request and its completion handler
            let request = VNRecognizeTextRequest { request, error in
                // Vision counters an error -> we unpause and throw it
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // safely cast the results; if it fails, unpause and return empty data
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: ScannedReceiptData())
                    return
                }
                // extract the most confident string (the first one) from each scanned line
                let recognizedStringArray = observations.compactMap { $0.topCandidates(1).first?.string }
                
                // sass the raw lines to our custom logic to extract the total amount
                let result = self.processResults(recognizedStrings: recognizedStringArray)
                
                continuation.resume(returning: result)
            }
            
            // configure recognition settings
            request.recognitionLanguages = ["hu-HU", "en-US"]
            request.recognitionLevel = .accurate
            
            // execute the request in the background
            // VNImageRequestHandler is synchronous, so we run it in a Task to avoid freezing the UI
            Task {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func processResults(recognizedStrings: [String]) -> ScannedReceiptData {
        var data = ScannedReceiptData()
        data.name = recognizedStrings.first
        
        // Checks if there is a total on the receipt
        let totalIdx = recognizedStrings.firstIndex(where: { $0.localizedCaseInsensitiveContains("total") }) ??
                       recognizedStrings.firstIndex(where: { $0.localizedCaseInsensitiveContains("összesen") }) ??
                       recognizedStrings.firstIndex(where: { $0.localizedCaseInsensitiveContains("osszesen") })
        
        let numbersRegex = /[0-9]+([.,][0-9])?/
        // if there is it enters a loop
        if let totalIdx = totalIdx {
            
            // we loop through from the foung "összesen" or "total" to the end of the list
            for idx in totalIdx..<recognizedStrings.count {
                // there is a number? we get it out and break the loop
                if let match = recognizedStrings[idx].firstMatch(of: numbersRegex) {
                    let extractedString = String(match.output.0)
                    
                    let cleanedString = extractedString.replacingOccurrences(of: ",", with: ".")
                    
                    let finalString = cleanedString.replacingOccurrences(of: " ", with: "")

                    
                    if let number = Decimal(string: finalString) {
                        data.amount = number
                        break
                    }
                }
            }
        }
        return data
    }
}

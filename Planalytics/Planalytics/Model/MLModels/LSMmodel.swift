//
//  LSMmodel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 04..
//

import Foundation


class LSMmodel {
    var m: Decimal
    var b: Decimal
    var transactions: [transHolder]?
    // X a tranzakciók értéke, Y a dátum, amit becsülni szeretnénk
    
    init(transactions: [transHolder]) {
        self.transactions = transactions
        
        let n = Decimal(transactions.count)
        let sumX = transactions.map{ $0.total }.reduce(0, +)
        let sumY = transactions.map{ Decimal($0.date.timeIntervalSince1970) }.reduce(0, +)
        let sumXY = zip(transactions.map{ $0.total }, transactions.map{ Decimal($0.date.timeIntervalSince1970) }).map(*).reduce(0, +)
        let sumX2 = transactions.map{ $0.total * $0.total }.reduce(0, +)
        
        let denominator = (n * sumX2 - sumX * sumX)
        
        if denominator != 0 {
            m = (n * sumXY - sumX * sumY) / denominator
            b = (sumY - m * sumX) / n
        } else {
            m = 0
            b = 0
        }
    }
    
    func predict(forX: Decimal) -> Date {
        let timeResult = NSDecimalNumber(decimal: ((m * forX) + b)).doubleValue
        
        return Date(timeIntervalSince1970: timeResult)
    }
    
    func getTValue(n: Int) -> Double {
        let df = n - 1
        if df < 1 { return 0.0 }
        
        let tValues: [Int: Double] = [
            1: 12.706,
            2: 4.303,
            3: 3.182,
            4: 2.776,
            5: 2.571,
            6: 2.447,
            7: 2.365,
            8: 2.306,
            9: 2.262,
            10: 2.228,
            11: 2.201,
            12: 2.179,
            13: 2.160,
            14: 2.145,
            15: 2.131,
            16: 2.120,
            17: 2.110,
            18: 2.101,
            19: 2.093,
            20: 2.086,
            21: 2.080,
            22: 2.074,
            23: 2.069,
            24: 2.064,
            25: 2.060,
            26: 2.056,
            27: 2.052,
            28: 2.048,
            29: 2.045,
            30: 2.042
        ]
        
        if let value = tValues[df] {
            return value
        }
        
        switch df {
        case 31...40:
            return 2.021
        case 41...60:
            return 2.000
        case 61...80:
            return 1.990
        case 81...100:
            return 1.984
        case 101...1000:
            return 1.962
        default:
            return 1.960
        }
    }
    
    func predictConfidenceIntervals(forX: Decimal) -> [Date] {
        guard let transactions, transactions.count > 2 else { return [] }
        
        let n = Double(transactions.count)
        
        // Alapelőrejelzés
        let yPredicted = (((m * forX) + b) as NSDecimalNumber).doubleValue
        
        // Reziduumok négyzetes összege ( Sum of Squared Errors)
        // Négyzetes hiba kiszámítása minden pontra a becsült és a valós értékek különbségének négyzetével
        var sse: Double = 0.0
        for transaction in transactions {
            let xValue = transaction.total
            let yActual = Decimal(transaction.date.timeIntervalSince1970)
            let yPred = (m * xValue) + b
            // hiba kiszámítása
            let residual = (yActual - yPred) as NSDecimalNumber
            sse += pow(residual.doubleValue, 2)
        }
        
        // Reziduumok standard hibája
        // Átlagos négyzetes hiba
        let mse = sse / (n - 2)  // n-2 a szabadságfok lineáris regressziónál
        // Átlagos hiba a négyzetes hiba gyökével
        let sResidual = sqrt(mse)
        
        // X értékek átlaga és négyzetösszege
        let sumX = transactions.map { $0.total }.reduce(0, +)
        let meanX = (sumX as NSDecimalNumber).doubleValue / n
        
        let sumX2 = transactions.map { pow(($0.total as NSDecimalNumber).doubleValue, 2) }.reduce(0, +)
        // X értékek négyzetes eltérése
        // Osztva az elemszámmal, megkapjuk a varianciát
        let sxx = sumX2 - n * pow(meanX, 2)
        
        // Standard hiba az előrejelzéshez
        let xValue = (forX as NSDecimalNumber).doubleValue
        let sePredict = sResidual * sqrt(1.0 / n + pow(xValue - meanX, 2) / sxx)
        
        // t-érték 95%-os konfidenciaszinthez
        // Student-féle eloszlásból
        let tValue = getTValue(n: Int(n))
        
        // Konfidenciaintervallum
        let marginOfError = tValue * sePredict
        
        let lowerBound = Date(timeIntervalSince1970: yPredicted - marginOfError)
        let upperBound = Date(timeIntervalSince1970: yPredicted + marginOfError)
        
        return [lowerBound, upperBound]
    }
    
}

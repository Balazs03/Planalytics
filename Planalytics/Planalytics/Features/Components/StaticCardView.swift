//
//  StaticCardView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 12..
//

import SwiftUI

struct StaticCardView: View {
    var text: String
    var value: Decimal
    var color: Color?
    var icon: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let icon {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color ?? .blue)
                    Spacer()
                }
            }
            Text(text)
                .foregroundStyle(.secondary)
            
            Text("\((value as NSDecimalNumber).doubleValue, specifier: "%.2f")")
                .fontWeight(.bold)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        
    }
}

#Preview {
    StaticCardView(text: "Átlagos befizetés", value: 3000, color: .red, icon: "creditcard.circle")
}

//
//  StaticCardView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 12..
//

import SwiftUI

struct StaticCardView: View {
    var text: String
    var value: String
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
            
            Text(value)
                .fontWeight(.bold)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding()
        .background(Color.appBackground.grayscale(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        
    }
}

#Preview {
    StaticCardView(text: "Átlagos befizetés", value: "3000", color: .red, icon: "creditcard.circle")
}

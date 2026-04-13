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

            
            HStack{
                Text(text)
                
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(color ?? .blue)
                        .font(.title)
                }
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .padding()
        .frame(height: 140)
        .background(.secondaryBackground.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        
    }
}

#Preview {
    StaticCardView(text: "Átlagos befizetés", value: "3000", color: .red, icon: "creditcard.circle")
}

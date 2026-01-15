//
//  InfoGroupView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 03..
//

import SwiftUI

struct InfoGroupView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.headline)
            Text(value)
                .font(.body)
        }
    }
}

#Preview {
    InfoGroupView(label: "Leírás", value: "Egy rövid leírás az oldal megjelenítésére")
}

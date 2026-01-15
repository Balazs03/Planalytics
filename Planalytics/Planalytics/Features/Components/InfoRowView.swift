//
//  InfoRowView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 03..
//

import SwiftUI

struct InfoRowView: View {
    let label : String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.appText.mix(with: .black, by: 0.2))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    let value: Decimal = 150.00
    InfoRowView(label: "Eddig félretett:", value: "\(value.formatted()) Ft")
}

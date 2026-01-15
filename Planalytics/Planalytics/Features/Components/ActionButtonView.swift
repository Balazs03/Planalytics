//
//  ActionButtonView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 03..
//

import SwiftUI

struct ActionButtonView: View {
    let label: String
    let icon: String
    let action: () -> Void
    var body: some View {
        VStack(alignment: .center) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 60, height: 60)
            }
            .padding()
            .buttonStyle(.glass)
            .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    let action: () -> Void = {  }
    ActionButtonView(label: "Hozzáadás", icon: "plus", action: action)
}

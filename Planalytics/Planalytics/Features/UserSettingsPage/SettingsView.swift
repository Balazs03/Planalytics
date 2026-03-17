//
//  SettingsView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 05..
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    
    @AppStorage("isLockEnabled") private var isLockEnabled: Bool = false
    @Environment(Coordinator.self) private var coordinator
    
    var body: some View {
        Form {
            Section(header: Text("Biztonság")) {
                Toggle(isOn: $isLockEnabled) {
                    Label("Alkalmazás zárolása", systemImage: "lock")
                }
                if isLockEnabled {
                    Button {
                        coordinator.present(sheet: .setPinCode)
                    } label: {
                        Label("Pin kód beállítása", systemImage: "key")
                    }
                }
            }
            
            Section(header: Text("Nyelv")) {
                Picker("Alkalmazás nyelv kiválasztása", selection: $appLanguage) {
                    Text("Magyar").tag("hu")
                    Text("Angol").tag("en")
                }
            }
        }
        .navigationTitle("Beállítások")
    }
}

#Preview {
    SettingsView()
}

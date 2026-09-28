//
//  BindingOptional.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 08. 04..
//

import SwiftUI

extension Binding where Value == String? {
    
    func bindOptionalString() -> Binding<String> {
        Binding<String> (
            get: { self.wrappedValue ?? "" },
            set: { newValue in
                self.wrappedValue = newValue.isEmpty ? nil : newValue
            }
        )
    }
}

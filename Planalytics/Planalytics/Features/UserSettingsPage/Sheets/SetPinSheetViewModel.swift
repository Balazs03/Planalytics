//
//  SetPinSheetViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 06..
//

import Foundation

@Observable
class  SetPinSheetViewModel {
    var currentPin = ""
    var firstSavedPin: String?
    var isValid: Bool {
        return !currentPin.isEmpty && currentPin == self.firstSavedPin && currentPin.count == 4
    }
    var isFirstPinSaved: Bool = false
    var animateField: Bool = false
}

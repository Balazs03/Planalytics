//
//  LockViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 04..
//

import Foundation

@Observable
class LockViewModel {
    var currentPin: String = ""
    var actualPin: String
    var lockType: LockTypes
    var isEnabled: Bool = false
    var isUnlocked: Bool = false
    var animateField: Bool = false
    var biometricAvailable: Bool = true
    
    init(currentPin: String, lockType: LockTypes, actualPin: String, isEnabled: Bool) {
        self.currentPin = currentPin
        self.lockType = lockType
        self.actualPin = actualPin
        self.isEnabled = isEnabled
    }
}

enum LockTypes: String {
    case numeric = "Custom number lock"
    case both = "Biometric or numeric unlock"
}

//
//  LockViewModel.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 04..
//

import Foundation
internal import LocalAuthentication

@Observable
class LockViewModel {
    var currentPin: String = ""
    var actualPin: String
    var lockType: LockTypes
    var isUnlocked: Bool
    var animateField: Bool = false
    var lockWhenAppGoesBackground: Bool = true
    let context = LAContext()
    var showAlert: Bool = false
    
    
    var isBiometricAvailable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    init(lockType: LockTypes, actualPin: String) {
        self.lockType = lockType
        self.actualPin = actualPin
        
        self.isUnlocked = !UserDefaults.standard.bool(forKey: "isLockedEnabled")
    }
    
    func unlockWithFaceID() {
        Task {
            if isBiometricAvailable && lockType != .numeric {
                if let result = try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Alkalmazás feloldása"), result {
                    isUnlocked = true
                    
                }
            }
        }
    }
    
    func getBiometricType() -> LABiometryType? {
        if #available(iOS 11, *) {
            switch (context.biometryType) {
            case .none:
                return Optional.none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            case .opticID:
                return .opticID

            @unknown default:
                return nil
            }
        }
    }
}

enum LockTypes: String {
    case numeric = "Custom number lock"
    case both = "Biometric or numeric unlock"
}
